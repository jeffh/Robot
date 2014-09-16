#import <UIKit/UIKit.h>
#import "RBMacros.h"
#import "RBViewQuery.h"


#pragma mark - View Fetching

RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allViews(void);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allViews(NSPredicate *predicate);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allViews(NSArray *predicates);

RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allSubviews(void);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allSubviews(NSPredicate *predicate);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_allSubviews(NSArray *predicates);

RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstView(void);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstView(NSPredicate *predicate);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstView(NSArray *predicates);

RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstSubview(void);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstSubview(NSPredicate *predicate);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *RB_theFirstSubview(NSArray *predicates);

RB_EXPORT BOOL RB_isAlertVisible(void); // uses private APIs

#pragma mark - View Mutation

RB_EXPORT RB_USES_PRIVATE_APIS void RB_removeAllAlerts(void);

#pragma mark - Sort Descriptors

RB_EXPORT NSSortDescriptor *RB_smallestOrigin(void);
RB_EXPORT NSSortDescriptor *RB_largestOrigin(void);

#pragma mark - View Querying

// Low-level querying
RB_EXPORT_OVERLOADED NSPredicate *RB_where(NSString *predicateFormat, ...);
RB_EXPORT_OVERLOADED NSPredicate *RB_where(BOOL(^matcher)(UIView *view));

RB_EXPORT NSPredicate *RB_includingSuperViews(NSPredicate *predicate);

RB_EXPORT NSPredicate *_RB_matching(NSArray *predicate);
#define RB_matching(...) (_RB_matching(@[__VA_ARGS__]))

// High-level querying
RB_EXPORT_OVERLOADED NSPredicate *RB_ofExactClass(Class aClass);
RB_EXPORT_OVERLOADED NSPredicate *RB_ofExactClass(NSString *className);
RB_EXPORT_OVERLOADED NSPredicate *RB_ofClass(Class aClass); // allows subclasses
RB_EXPORT_OVERLOADED NSPredicate *RB_ofClass(NSString *className); // allows subclasses
RB_EXPORT NSPredicate *RB_withText(NSString *text);
RB_EXPORT NSPredicate *RB_withLabel(NSString *accessibilityLabelOrText);
RB_EXPORT NSPredicate *RB_withTraits(UIAccessibilityTraits traits);
RB_EXPORT NSPredicate *RB_withVisibility(BOOL isVisible); // checks isHidden property
RB_EXPORT NSPredicate *RB_withImage(UIImage *image);
RB_EXPORT NSPredicate *RB_withAccessibility(BOOL isAccessibilityView);
RB_EXPORT NSPredicate *RB_onScreen(BOOL isOnScreen); // intersects or is inside the screen bounds
RB_EXPORT NSPredicate *RB_onScreenAndVisible(BOOL isVisible); // the view and all parents are visible
RB_EXPORT NSPredicate *RB_withParent(NSPredicate *predicateForParent);
RB_EXPORT NSPredicate *RB_withoutRootView(void);

#pragma mark - View Interaction
// All interactions use private APIs

// Low-level Touches
RB_EXPORT RB_USES_PRIVATE_APIS void RB_touchAndMoveLinearlyOn(id viewOrViews, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints);
RB_EXPORT RB_USES_PRIVATE_APIS void RB_touchAndMoveLinearlyAroundPointOn(id viewOrViews, CGPoint center, CGPoint delta, NSUInteger numOfIntermediatePoints);
RB_EXPORT RB_USES_PRIVATE_APIS void RB_touchAndMoveLinearlyFromCenterOf(id viewOrViews, CGPoint delta, NSUInteger numOfIntermediatePoints);

// Taps
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_tapOn(id viewOrViews);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_tapOn(id viewOrViews, CGPoint pointRelativeToSuperView);

// Swipes
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeLeftOn(id viewOrViews, CGFloat swipeWidth);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeRightOn(id viewOrViews, CGFloat swipeWidth);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeUpOn(id viewOrViews, CGFloat swipeHeight);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeDownOn(id viewOrViews, CGFloat swipeHeight);

RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeLeftOn(id viewOrViews);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeRightOn(id viewOrViews);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeUpOn(id viewOrViews);
RB_EXPORT_OVERLOADED RB_USES_PRIVATE_APIS void RB_swipeDownOn(id viewOrViews);

// Pinch

// Rotate

// Long Press


#pragma mark - Aliases
// below lists all the same functions as above, with RB_ removed if
// the RB_DISABLE_SHORTHAND is NOT defined.

#ifndef RB_DISABLE_SHORTHAND

#define RB_ALIAS RB_INLINE
#define RB_ALIAS_OVERLOADED RB_ALIAS __attribute__((overloadable))

#pragma mark View Fetching

// uses private APIs
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allViews(void) {
    return RB_allViews();
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allViews(NSPredicate *predicate) {
    return RB_allViews(predicate);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allViews(NSArray *predicates) {
    return RB_allViews(predicates);
}

RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allSubviews(void) {
    return RB_allSubviews();
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allSubviews(NSPredicate *predicate) {
    return RB_allSubviews(predicate);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *allSubviews(NSArray *predicates) {
    return RB_allSubviews(predicates);
}

RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstView(void) {
    return RB_theFirstView();
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstView(NSPredicate *predicate) {
    return RB_theFirstView(predicate);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstView(NSArray *predicates) {
    return RB_theFirstView(predicates);
}

RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstSubview(void) {
    return RB_theFirstSubview();
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstSubview(NSPredicate *predicate) {
    return RB_theFirstSubview(predicate);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS RBViewQuery *theFirstSubview(NSArray *predicates) {
    return RB_theFirstSubview(predicates);
}

RB_ALIAS RB_USES_PRIVATE_APIS BOOL isAlertVisible(void) {
    return RB_isAlertVisible();
}

#pragma mark View Mutation

RB_ALIAS RB_USES_PRIVATE_APIS void removeAllAlerts(void) {
    RB_removeAllAlerts();
}

#pragma mark - Sort Descriptors

RB_ALIAS NSSortDescriptor *smallestOrigin(void) { return RB_smallestOrigin(); }
RB_ALIAS NSSortDescriptor *largestOrigin(void) { return RB_largestOrigin(); }

#pragma mark View Querying

RB_ALIAS_OVERLOADED NSPredicate *where(BOOL(^matcher)(UIView *view)) {
    return RB_where(matcher);
}
RB_ALIAS NSPredicate *includingSuperViews(NSPredicate *predicate) {
    return RB_includingSuperViews(predicate);
}

#define matching RB_matching

RB_ALIAS_OVERLOADED NSPredicate *where(NSString *predicateFormat, ...) {
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

RB_ALIAS_OVERLOADED NSPredicate *ofExactClass(Class aClass) { return RB_ofExactClass(aClass); }
RB_ALIAS_OVERLOADED NSPredicate *ofExactClass(NSString *className) { return RB_ofExactClass(className); }
RB_ALIAS_OVERLOADED NSPredicate *ofClass(Class aClass) { return RB_ofClass(aClass); }
RB_ALIAS_OVERLOADED NSPredicate *ofClass(NSString *className) { return RB_ofClass(className); }
RB_ALIAS NSPredicate *withText(NSString *text) { return RB_withText(text); }
RB_ALIAS NSPredicate *withLabel(NSString *accessibilityLabelOrText) {
    return RB_withLabel(accessibilityLabelOrText);
}
RB_ALIAS NSPredicate *withTraits(UIAccessibilityTraits traits) {
    return RB_withTraits(traits);
}
RB_ALIAS NSPredicate *withVisibility(BOOL isVisible) { return RB_withVisibility(isVisible); }
RB_ALIAS NSPredicate *withImage(UIImage *image) { return RB_withImage(image); }
RB_ALIAS NSPredicate *withAccessibility(BOOL isAccessibilityView) {
    return RB_withAccessibility(isAccessibilityView);
}
RB_ALIAS NSPredicate *onScreen(BOOL isOnScreen) { return RB_onScreen(isOnScreen); }
RB_ALIAS NSPredicate *onScreenAndVisible(BOOL isVisible) { return RB_onScreenAndVisible(isVisible); }
RB_ALIAS NSPredicate *withParent(NSPredicate *predicateForParent) {
    return RB_withParent(predicateForParent);
}
RB_ALIAS NSPredicate *withoutRootView(void) { return RB_withoutRootView(); }

#pragma mark View Interactions

// Taps
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void tapOn(id viewOrViews) { RB_tapOn(viewOrViews); }
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void tapOn(id viewOrViews, CGPoint pointRelativeToSuperView) {
    RB_tapOn(viewOrViews, pointRelativeToSuperView);
}

// Swipes
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeLeftOn(id viewOrViews, CGFloat swipeWidth) {
    RB_swipeLeftOn(viewOrViews, swipeWidth);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeRightOn(id viewOrViews, CGFloat swipeWidth) {
    RB_swipeRightOn(viewOrViews, swipeWidth);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeUpOn(id viewOrViews, CGFloat swipeHeight) {
    RB_swipeUpOn(viewOrViews, swipeHeight);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeDownOn(id viewOrViews, CGFloat swipeHeight) {
    RB_swipeDownOn(viewOrViews, swipeHeight);
}

RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeLeftOn(id viewOrViews) {
    RB_swipeLeftOn(viewOrViews);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeRightOn(id viewOrViews) {
    RB_swipeRightOn(viewOrViews);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeUpOn(id viewOrViews) {
    RB_swipeUpOn(viewOrViews);
}
RB_ALIAS_OVERLOADED RB_USES_PRIVATE_APIS void swipeDownOn(id viewOrViews) {
    RB_swipeDownOn(viewOrViews);
}

#undef RB_ALIAS

#endif
