#import <UIKit/UIKit.h>

#define RB_EXPORT FOUNDATION_EXTERN __attribute__((overloadable))
#define RB_INLINE FOUNDATION_STATIC_INLINE __attribute__((overloadable))

#ifndef RB_DISABLE_SHORTHAND
#define RB_SHORTHAND(PROTO, BODY) RB_INLINE PROTO { return (BODY); }
#else
#define RB_SHORTHAND(PROTO, BODY)
#endif


#pragma mark - View Fetching

RB_EXPORT NSArray *RB_allViews(void); // uses private APIs
RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate); // uses private APIs
RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate, UIView *viewToSearch);

RB_EXPORT NSArray *RB_allSubViews(void);
RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate); // uses private APIs
RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate, UIView *viewToSearch);

RB_EXPORT id RB_theFirstView(void); // uses private APIs
RB_EXPORT id RB_theFirstView(NSPredicate *predicate); // uses private APIs
RB_EXPORT id RB_theFirstView(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT id RB_theFirstView(NSPredicate *predicate, UIView *viewToSearch);

RB_EXPORT BOOL RB_isView(NSPredicate *predicate, UIView *view);
RB_EXPORT BOOL RB_isAlertVisible(void); // uses private APIs

#pragma mark - View Mutation

RB_EXPORT void RB_removeAllAlerts(void); // uses private APIs

#pragma mark - View Querying

// Low-level querying
RB_EXPORT NSPredicate *RB_where(NSString *predicateFormat, ...);
RB_EXPORT NSPredicate *RB_where(BOOL(^matcher)(UIView *view));

RB_EXPORT NSPredicate *RB_includingSuperViews(NSPredicate *predicate);

RB_EXPORT NSPredicate *_RB_matching(NSArray *predicate);
#define RB_matching(...) (_RB_matching(@[__VA_ARGS__]))

// High-level querying
RB_EXPORT NSPredicate *RB_ofExactClass(Class aClass);
RB_EXPORT NSPredicate *RB_ofClass(Class aClass); // allows subclasses
RB_EXPORT NSPredicate *RB_withLabel(NSString *accessibilityLabelOrText);
RB_EXPORT NSPredicate *RB_withTraits(UIAccessibilityTraits traits);
RB_EXPORT NSPredicate *RB_withVisibility(BOOL isVisible); // checks isHidden property
RB_EXPORT NSPredicate *RB_withAccessibility(BOOL isAccessibilityView);
RB_EXPORT NSPredicate *RB_onScreen(void); // intersects or is inside the screen bounds
RB_EXPORT NSPredicate *RB_thatCanBeSeen(BOOL isVisible); // the view and all parents are visible

#pragma mark - View Interaction
// All interactions use private APIs

// Taps
RB_EXPORT void RB_tapOn(id view);
RB_EXPORT void RB_tapOn(id view, CGPoint pointRelativeToView);

// Low-level Touches
RB_EXPORT void RB_touchAndMoveLinearlyOn(id view, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints);
RB_EXPORT void RB_touchAndMoveLinearlyAroundPointOn(id view, CGPoint center, CGPoint delta, NSUInteger numOfIntermediatePoints);
RB_EXPORT void RB_touchAndMoveLinearlyFromCenterOf(id view, CGPoint delta, NSUInteger numOfIntermediatePoints);

// Swipes
RB_EXPORT void RB_swipeLeftOn(id view, CGFloat swipeWidth);
RB_EXPORT void RB_swipeRightOn(id view, CGFloat swipeWidth);
RB_EXPORT void RB_swipeUpOn(id view, CGFloat swipeHeight);
RB_EXPORT void RB_swipeDownOn(id view, CGFloat swipeHeight);

RB_EXPORT void RB_swipeLeftOn(id view);
RB_EXPORT void RB_swipeRightOn(id view);
RB_EXPORT void RB_swipeUpOn(id view);
RB_EXPORT void RB_swipeDownOn(id view);

// Pinch

// Rotate

// Long Press


#pragma mark - Aliases
// below lists all the same functions as above, with RB_ removed if
// the RB_DISABLE_SHORTHAND is NOT defined.

#pragma mark View Fetching

RB_SHORTHAND(NSArray *allViews(void),
             RB_allViews());  // uses private APIs
RB_SHORTHAND(NSArray *allViews(NSPredicate *predicate),
             RB_allViews(predicate));  // uses private APIs
RB_SHORTHAND(NSArray *allViews(NSPredicate *predicate, NSArray *viewsToSearch),
             RB_allViews(predicate, viewsToSearch));
RB_SHORTHAND(NSArray *allViews(NSPredicate *predicate, UIView *viewToSearch),
             RB_allViews(predicate, viewToSearch));

RB_SHORTHAND(NSArray *allSubViews(void),
             RB_allSubViews()); // uses private APIs
RB_SHORTHAND(NSArray *allSubViews(NSPredicate *predicate),
             RB_allSubViews(predicate)); // uses private APIs
RB_SHORTHAND(NSArray *allSubViews(NSPredicate *predicate, NSArray *viewsToSearch),
             RB_allSubViews(predicate, viewsToSearch));
RB_SHORTHAND(NSArray *allSubViews(NSPredicate *predicate, UIView *viewToSearch),
             RB_allSubViews(predicate, viewToSearch));
RB_SHORTHAND(id theFirstView(void),
             RB_theFirstView()); // uses private APIs
RB_SHORTHAND(id theFirstView(NSPredicate *predicate),
             RB_theFirstView(predicate)); // uses private APIs
RB_SHORTHAND(id theFirstView(NSPredicate *predicate, NSArray *viewsToSearch),
             RB_theFirstView(predicate, viewsToSearch));
RB_SHORTHAND(id theFirstView(NSPredicate *predicate, UIView *viewToSearch),
             RB_theFirstView(predicate, viewToSearch));

RB_SHORTHAND(BOOL isView(NSPredicate *predicate, UIView *view),
             RB_isView(predicate, view));
RB_SHORTHAND(BOOL isAlertVisible(void),
             RB_isAlertVisible()); // uses private APIs

#pragma mark View Mutation

RB_SHORTHAND(void removeAllAlerts(void), RB_removeAllAlerts()); // uses private APIs

#pragma mark View Querying

RB_SHORTHAND(NSPredicate *where(BOOL(^matcher)(UIView *view)),
             RB_where(matcher));
RB_SHORTHAND(NSPredicate *includingSuperViews(NSPredicate *predicate),
             RB_includingSuperViews(predicate));

#ifndef RB_DISABLE_SHORTHAND
#define matching RB_matching

RB_INLINE NSPredicate *where(NSString *predicateFormat, ...) {
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

#endif

RB_SHORTHAND(NSPredicate *ofExactClass(Class aClass),
             RB_ofExactClass(aClass));
RB_SHORTHAND(NSPredicate *ofClass(Class aClass),
             RB_ofClass(aClass)); // allows subclasses
RB_SHORTHAND(NSPredicate *withLabel(NSString *accessibilityLabelOrText),
             RB_withLabel(accessibilityLabelOrText));
RB_SHORTHAND(NSPredicate *withTraits(UIAccessibilityTraits traits),
             RB_withTraits(traits));
RB_SHORTHAND(NSPredicate *withVisibility(BOOL isVisible),
             RB_withVisibility(isVisible)); // checks isHidden property
RB_SHORTHAND(NSPredicate *withAccessibility(BOOL isAccessibilityView),
             RB_withAccessibility(isAccessibilityView));
RB_SHORTHAND(NSPredicate *onScreen(void),
             RB_onScreen()); // intersects or is inside the screen bounds
RB_SHORTHAND(NSPredicate *thatCanBeSeen(BOOL isVisible),
             RB_thatCanBeSeen(isVisible)); // the view and all parents are visible

#pragma mark View Interactions

// Taps
RB_SHORTHAND(void tapOn(id view), RB_tapOn(view));
RB_SHORTHAND(void tapOn(id view, CGPoint pointRelativeToView), RB_tapOn(view, pointRelativeToView));

// Swipes
RB_SHORTHAND(void swipeLeftOn(id view, CGFloat swipeWidth), RB_swipeLeftOn(view, swipeWidth));
RB_SHORTHAND(void swipeRightOn(id view, CGFloat swipeWidth), RB_swipeRightOn(view, swipeWidth));
RB_SHORTHAND(void swipeUpOn(id view, CGFloat swipeHeight), RB_swipeUpOn(view, swipeHeight));
RB_SHORTHAND(void swipeDownOn(id view, CGFloat swipeHeight), RB_swipeDownOn(view, swipeHeight));

RB_SHORTHAND(void swipeLeftOn(id view), RB_swipeLeftOn(view));
RB_SHORTHAND(void swipeRightOn(id view), RB_swipeRightOn(view));
RB_SHORTHAND(void swipeUpOn(id view), RB_swipeUpOn(view));
RB_SHORTHAND(void swipeDownOn(id view), RB_swipeDownOn(view));
