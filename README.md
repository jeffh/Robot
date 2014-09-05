Robot
=====

An integration test library on UIKit. Easily emulate high-level user interaction
through UIKit.

Unlike KIF, this does not aim to perfectly emulate how users interact with
the system. Instead, trying to replicate the same behavior while minimizing
the overhead of time-based operations. A perfect example is disabling animations
to speed up running of tests.

Also unlike KIF, Robot does not aim to be a full integration testing solution. Rather,
it relies on other testing frameworks to do assertion and running. Besides XCTest, there
are some popular BDD frameworks:

 - Cedar
 - Specta / Expecta
 - Kiwi

And like KIF, this uses private APIs.

```objc
// tap on a cancel button/label
tapOn(theFirstView(withLabel(@"Cancel")));
```

Components
==========

There are 4 main parts to this library:

 - View Query - Provides an API to find views and manage alerts.
 - Keyboard - Provides an API to interact with the system default keyboard.
 - Touch - Provides an API to interact with views.
 - TimeLapse - Provides an API to speed up time-based operations (Animations + RunLoop).

View Query
==========

This component provides a DSL to find for views. They're built upon recursive
subview walking and NSPredicate.

There are core functions to find views:

- ``RBViewQuery *allViews([NSPredicate *predicate)`` - Returns all the views (and subviews) that satisfies the predicate in the given scope. The default scope is keyWindow.
- ``RBViewQuery *allSubviews([NSPredicate *predicate)`` - Returns all the subviews that satisfies the predicate in the given scope. The default scope is keyWindow.
- ``RBViewQuery *theFirstView([NSPredicate *predicate)`` - Returns the first view (or subview) that satisfies the predicate in the given scope. The default scope is the keyWindow.
- ``RBViewQuery *theFirstSubview([NSPredicate *predicate)`` - Returns the first subview that satisfies the predicate in the given scope. The default scope is the keyWindow.

Predicates
----------

All the core methods accept a predicate to check if each view satisfies
the requirement. You can build your own from NSPredicate, but Robot comes
with some built-in ones to compose:

``where(NSString *formatString, ...)`` is an alias to ``+[NSPredicate predicateWithFormat:predicateFormat, ...]``:
Likewise, ``NSPredicate *where(BOOL(^matcher)(UIView *view))`` is an alias to ``+[NSPredicate predicateWithBlock:matcher]``

```objc
// finds all views that have more than 2 subviews
allViews(where(@"subviews.count > %@", @2));

// finds all views that have a tag of 3
allViews(where(^BOOL(UIView *view){
    return view.tag == 3;
}));
```

Building up from that, the ``matching(...)`` macro is an alias to ``+[NSCompoundPredicate andPredicateWithSubpredicates:@[...]]``:

```objc
// find all views with tag of 3 with more than 2 subviews.
allViews(matching(where(@"subviews.count > 2"), where(@"tag == 3")));
```

There is are methods of filtering by the classes of views:

```objc
// find all UITextViews, but not subclasses
allViews(ofExactClass([UITextView class]));
allViews(ofExactClass(@"UITextView"));

// find all UIButtons and subclasses
allViews(ofClass([UIButton class]));
allViews(ofClass(@"UIButton"));
```

You can also filter by parent view state:

```objc
// find all views that have UIViews as superviews
allViews(withParent(ofExactClass([UIView class])));

// find all views that have superviews that have UIView classes. This includes
// the root view.
allViews(includingSuperViews(ofExactClass([UIView class])));

// all views, excluding the root view
allViews(withoutRootView());
```

Or by content:

```objc
// find any views with the text of "Cancel"
allViews(withText(@"Cancel"));

// find any views with the text or accessibilityLabel of "Cancel"
allViews(withLabel(@"Cancel"));

// find any views with the EXACT image
allViews(withImage([UIImage imageNamed:@"myImage"]));

// find any views behaviorally acts like a button
allViews(withTraits(UIAccessibilityTraitButton));

// find any views that are accessible
allViews(withAccessibility(YES));
```

Finally, by visibility:

```objc
// find all views that are visible (isHidden = NO and alpha > 0 and a drawable pixel)
// a drawable pixel is where clipsToBounds is NO or a non-zero size
allViews(withVisibility(YES));

// find all views that are on screen. On screen means the view's rect intersects or is
// inside the window. If not in a window, the root view is used instead.
allViews(onScreen(YES));

// find all views that are visible and on screen -- including all their superviews.
// This is a combination of withVisibility() and onScreen() with includingSuperViews().
allViews(onScreenAndVisible(YES));
```

Refining the Query
------------------

All the core query methods return `RBViewQuery`, which are lazy NSArrays of the views.
They can be further refined used property-blocks. For example, to restrict the query
to a given view:

```objc
// returns views with text "hello" that are either myView or any of its subviews
allViews(withText(@"Hello")).inside(myView);

// if you want to search inside multiple disperate view hierarchies
allViews(withText(@"Hello")).insideOneOf(@[myView1, myView2]);
```

Sorting can also be applied with an array of ``NSSortDescriptors``:

```
// sort all the views by smallest origin first. Smallest is by y first, then x.
allViews(...).sortedBy(@[smallestOrigin()]);
// reverse sort
allViews(...).sortedBy(@[largestOrigin()]);

// sort all the views by smallest size first. Smallest is by height first, then width.
allViews(...).sortedBy(@[smallestSize()]);
// reverse sort
allViews(...).sortedBy(@[largestSize()]);
```

All these can be chained:

```
allViews(...).inside(myView).sortedBy(@[smallestOrigin()]);
```

Table Views
-----------

Verifying behavior of table views would still be cumbersome without some model to inspect
the table without explicitly scrolling. Use ``RBTableViewCellsProxy``:

```
RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:tableView];
cells[0] // -> Returns proxy to the first table view's cell
[cells[0] textLabel].text // works as expected
cells[100] // -> Returns another proxy
[cells[100] textLabel].text // works. Table view is scrolled before accessed.
```


Keyboard
========

Robot wraps UIKit's keyboard with a basic interface to control it. The
interface is on ``RBKeyboard``:

```
// focus a text field to get keyboard focus
tapOn(textField);

// type through the keyboard
[[RBKeyboard mainKeyboard] typeString:@"Hello World!"];

// dismiss the keyboard - you must always do this otherwise the next
// time you use the keyboard it might crash.
[[RBKeyboard mainKeyboard] dismiss];
```

To type special characters on the keyboard use ``-[typeKey:]`` instead:

```
// press delete key
[[RBKeyboard mainKeyboard] typeKey:RBKeyDelete];
```

Touch
=====

Robot implements its own UITouch subclass, ``RBTouch``, that simulates touch
events through your application. You can emulate any complex touch interaction
to your application with this class.

Along with ``RBTouch`` there are DSL functions that can keep you syntax concise for tests.

The most common action are to tap elements:

```
tapOn(myButton);
tapOn(myViewQuery);
```

But more complex gestures are supported:

```
swipeLeftOn(myView);
swipeUpOn(myView);
swipeDownOn(myView);
swipeRightOn(myView);
```

Time Lapse
==========

Robot can optionally speed up specific operations as needed. To disable animations under
test and call any completion blocks, use the ``-[disableAnimationsInBlock:]`` API:

```
[RBTimeLapse disableAnimationsInBlock:^{
    [UIView animateWithDuration:2 animations:^{
        view.x = 200;        
    } completion:^(BOOL finished){
        view.hidden = YES;
    }];
}];

view.isHidden // => YES;
```

Internally, ``RBTimeLapse`` will advance the run loop while disabling animations
and set timer delays to zero.

If you just want the latter without disabling animations, you can do:

```
[logger performSelector:@selector(logMessage:) withObject:@"hello" afterDelay:1];
[RBTimeLapse advanceMainRunLoop]; // calls [logger logMessage:@"hello"]
```

Time lapsing is automatic for ``tapOn``, but not for any other gestures.

