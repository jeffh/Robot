#import <UIKit/UIKit.h>

#define RB_EXPORT FOUNDATION_EXTERN __attribute__((overloadable))
///////////////////
// View Fetching //
///////////////////

RB_EXPORT NSArray *allViews(void);
RB_EXPORT NSArray *allViews(NSPredicate *predicate);
RB_EXPORT NSArray *allViews(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT NSArray *allViews(NSPredicate *predicate, UIView *viewToSearch);

RB_EXPORT id theFirstView(void);
RB_EXPORT id theFirstView(NSPredicate *predicate);
RB_EXPORT id theFirstView(NSPredicate *predicate, NSArray *viewsToSearch);
RB_EXPORT id theFirstView(NSPredicate *predicate, UIView *viewToSearch);

///////////////////
// View Querying //
///////////////////

// Low-level querying
RB_EXPORT NSPredicate *where(NSString *predicateFormat, ...);
RB_EXPORT NSPredicate *where(BOOL(^matcher)(UIView *view));

RB_EXPORT NSPredicate *RB_all(NSArray *predicate);
#define matching(PREDICATES) (RB_all(@[PREDICATES]))

// High-level querying
RB_EXPORT NSPredicate *ofExactClass(Class aClass);
RB_EXPORT NSPredicate *ofClass(Class aClass);
RB_EXPORT NSPredicate *withLabel(NSString *accessibilityLabel);
RB_EXPORT NSPredicate *withTraits(UIAccessibilityTraits traits);
RB_EXPORT NSPredicate *withVisibility(BOOL isVisible);
RB_EXPORT NSPredicate *withAccessibility(BOOL isAcessibilityView);
RB_EXPORT NSPredicate *onScreen(void);

//////////////////////
// View Interaction //
//////////////////////

// Taps
RB_EXPORT void tapOn(id view);
RB_EXPORT void tapOn(id view, CGPoint pointRelativeToView);

// Low-level Touches
RB_EXPORT void touchAndMoveLinearly(id view, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints);
RB_EXPORT void touchAndMoveLinearlyAroundPoint(id view, CGPoint center, CGPoint delta, NSUInteger numOfIntermediatePoints);
RB_EXPORT void touchAndMoveLinearlyFromCenter(id view, CGPoint delta, NSUInteger numOfIntermediatePoints);

// Swipes
RB_EXPORT void swipeLeftOn(id view, CGFloat swipeWidth);
RB_EXPORT void swipeRightOn(id view, CGFloat swipeWidth);
RB_EXPORT void swipeUpOn(id view, CGFloat swipeHeight);
RB_EXPORT void swipeDownOn(id view, CGFloat swipeHeight);

RB_EXPORT void swipeLeftOn(id view);
RB_EXPORT void swipeRightOn(id view);
RB_EXPORT void swipeUpOn(id view);
RB_EXPORT void swipeDownOn(id view);
