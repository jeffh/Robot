Robot
=====

An integration test library on UIKit. Easily emulate high-level user interaction
through UIKit.

Unlike KIF, this does not aim to perfectly emulate how users interact with
the system. Instead, trying to replicate the same behavior while minimizing
the overhead of time-based operations. A perfect example is disabling animations
to speed up running of tests.

And like KIF, this uses private APIs.

```
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

- ``NSPredicate *where(NSString *formatString, ...)`` - An alias to ``+[NSPredicate predicateWithFormat:predicateFormat, ...]``
- ``NSPredicate *where(BOOL(^matcher)(UIView *view))`` - An alias to ``+[NSPredicate predicateWithBlock:matcher]``
- ``NSPredicate *matching(...)`` - An alias to ``+[NSCompoundPredicate andPredicateWithSubpredicates:@[...]]``
- ``NSPredicate *includingSuperViews(NSPredicate *predicate)`` - A predicate that enforces all superviews also satisfy the given predicate.
- ``NSPredicate *ofExactClass(Class aClass)`` - A predicate that filters views of a particular class
- ``NSPredicate *ofClass(Class aClass)`` - A predicate that filters views of a particular class or subclass
- ``NSPredicate *withLabel(NSString *accessibilityLabelOrText)`` - A predicate that filters views by their accessibilityLabel or text property
- ``NSPredicate *withTraits(UIAccessibilityTraits traits)`` - A predicate that filters views containing the given UIAccessibilityTrait.
- ``NSPredicate *withVisibility(BOOL isVisible)`` - A predicate that filters by the view's ``isHidden`` property.
- ``NSPredicate *withAccessibility(BOOL isAccessibilityView)`` - A predicate that filters views that indicate they are accessible
- ``NSPredicate *onScreen(BOOL isOnScreen)`` - A predicate that filters views that do not fit on the screen bounds. If the view is not in a window, the root view is treated like the window.
- ``NSPredicate *thatCanBeSeen(BOOL isVisible)`` - A predicate that filters for views that are "visible" by the user which follows the criteria:
    - The ``isHidden`` property is ``NO``
    - The view is ``onScreen``
    - The view has a non-zero ``alpha`` value
    - The view has ``clipsToBounds`` as ``NO`` OR the view has a non-zero size.

Refining the Query
------------------

All the core query methods return `RBViewQuery`, which are lazy NSArrays of the views.
They can be further refined used property-blocks. For example, to restrict the query
to a given view:

```
// returns views with text "hello"
allViews(withText(@"Hello")).inside(myView);
```

Sorting can also be applied:

```
allViews(...).sortedBy(smallestOrigin());
```

All these can be chained:

```
allViews(...).inside(myView).sortedBy(smallestOrigin());
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
// dismiss the keyboard
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
