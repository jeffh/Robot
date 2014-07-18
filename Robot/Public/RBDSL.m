#import "RBDSL.h"
#import "RBAccessibility.h"
#import "RBTouch.h"
#import "NSObject+RBKVCUndefined.h"
#import "RBAnimation.h"


RB_EXPORT NSArray *allViews(void) {
    return allViews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT NSArray *allViews(NSPredicate *predicate) {
    return allViews(predicate, [[RBAccessibility sharedInstance] windows]);
}

RB_EXPORT NSArray *allViews(NSPredicate *predicate, NSArray *viewsToSearch) {
    NSPredicate *ignoreNoisyViews = where(@"class != %@", NSClassFromString(@"_UIBackdropEffectView"));
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ignoreNoisyViews, predicate]];
    [UIView RB_allowUndefinedKeys:YES];
    NSArray *results = [[RBAccessibility sharedInstance] subviewsOfViews:viewsToSearch
                                                     satisfyingPredicate:predicate];
    [UIView RB_allowUndefinedKeys:NO];
    return results;
}

RB_EXPORT NSArray *allViews(NSPredicate *predicate, UIView *viewToSearch) {
    return allViews(predicate, @[viewToSearch]);
}

RB_EXPORT id theFirstView(void) {
    return theFirstView([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT id theFirstView(NSPredicate *predicate) {
    return [allViews(predicate) firstObject];
}

RB_EXPORT id theFirstView(NSPredicate *predicate, NSArray *viewsToSearch) {
    return [allViews(predicate, viewsToSearch) firstObject];
}

RB_EXPORT id theFirstView(NSPredicate *predicate, UIView *viewToSearch) {
    return [allViews(predicate, viewToSearch) firstObject];
}

RB_EXPORT NSPredicate *_all(NSArray *predicates) {
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

RB_EXPORT NSPredicate *ofExactClass(Class aClass) {
    return where(@"class == %@", aClass);
}

RB_EXPORT NSPredicate *ofClass(Class aClass) {
    return where(@"self isKindOfClass: %@", aClass);
}

RB_EXPORT NSPredicate *withLabel(NSString *accessibilityLabel) {
    return where(@"accessibilityLabel == %@ OR text == %@",
                 accessibilityLabel, accessibilityLabel);
}

RB_EXPORT NSPredicate *withTraits(UIAccessibilityTraits traits) {
    return where(^BOOL(UIView *view) {
        return (view.accessibilityTraits & traits) == traits;
    });
}

RB_EXPORT NSPredicate *withAccessibility(BOOL isAcessibilityView) {
    return where(@"isAccessibilityElement == %@", isAcessibilityView);
}

RB_EXPORT NSPredicate *withVisibility(BOOL isVisible) {
    return where(@"hidden == %@", !isVisible);
}

RB_EXPORT NSPredicate *onScreen(void) {
    return where(^BOOL(UIView *view) {
        UIWindow *window = view.window;
        CGRect viewFrameInWindow = [view convertRect:view.frame toView:window];
        return CGRectIntersectsRect(viewFrameInWindow, window.frame) || CGRectContainsRect(window.frame, viewFrameInWindow);
    });
}

RB_EXPORT NSPredicate *where(NSString *predicateFormat, ...) {
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

RB_EXPORT NSPredicate *where(BOOL(^matcher)(UIView *view)) {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return matcher(evaluatedObject);
    }];
}

RB_EXPORT void tapOn(id view) {
    tapOn(view, [view center]);
}

RB_EXPORT void tapOn(id view, CGPoint pointRelativeToView) {
    NSCAssert(view, @"A view wasn't given to be tapped on");
    [RBAnimation disableAnimationsInBlock:^{
        [RBTouch tapOnView:view atPoint:pointRelativeToView];
    }];
}

RB_EXPORT void touchAndMove(id view, CGPoint *points, NSUInteger numOfPoints) {
    NSCAssert(view, @"A view wasn't given to be tapped on");
    NSCAssert(numOfPoints, @"Expected at least 1 point");
    __block RBTouch *touch;
    [RBAnimation disableAnimationsInBlock:^{
        touch = [RBTouch touchOnView:view atPoint:points[0] phase:UITouchPhaseBegan];
    }];
    for (NSUInteger i = 1; i < numOfPoints; i++) {
        [touch updateRelativePoint:points[i]];
        [touch updatePhase:(i + 1 == numOfPoints ? UITouchPhaseEnded : UITouchPhaseMoved)];
        [touch sendEvent];
    }
}

RB_EXPORT void touchAndMoveLinearlyOn(id view, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints) {
    NSUInteger numPoints = numOfIntermediatePoints + 2;
    CGPoint delta = CGPointMake((end.x - start.x) / numPoints,
                                (end.y - start.y) / numPoints);
    CGPoint *points = alloca(numPoints * sizeof(CGPoint));
    points[0] = start;
    for (NSUInteger i = 1; i < numPoints - 1; i++) {
        points[i] = CGPointMake(points[i-1].x + delta.x, points[i-1].y + delta.y);
    }
    points[numPoints - 1] = end;
    touchAndMove(view, points, numPoints);
}

RB_EXPORT void touchAndMoveLinearlyAroundPointOn(id view, CGPoint center, CGPoint delta, NSUInteger numOfIntermediatePoints) {
    CGPoint start = CGPointMake(center.x - delta.x, center.y - delta.y);
    CGPoint end = CGPointMake(center.x + delta.x, center.y + delta.y);
    touchAndMoveLinearlyOn(view, start, end, numOfIntermediatePoints);
}

RB_EXPORT void touchAndMoveLinearlyFromCenterOf(id view, CGPoint delta, NSUInteger numOfIntermediatePoints) {
    touchAndMoveLinearlyAroundPointOn(view, [view center], delta, numOfIntermediatePoints);
}

const NSUInteger kRBDefaultNumberOfIntermediatePoints = 5;

RB_EXPORT void swipeLeftOn(id view, CGFloat swipeWidth) {
    touchAndMoveLinearlyFromCenterOf(view, CGPointMake(-swipeWidth / 2, 0), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void swipeRightOn(id view, CGFloat swipeWidth) {
    touchAndMoveLinearlyFromCenterOf(view, CGPointMake(swipeWidth / 2, 0), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void swipeUpOn(id view, CGFloat swipeHeight) {
    touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, -swipeHeight / 2), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void swipeDownOn(id view, CGFloat swipeHeight) {
    touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, swipeHeight), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void swipeLeftOn(id view) {
    swipeLeftOn(view, CGRectGetWidth([view bounds]) / 2);
}

RB_EXPORT void swipeRightOn(id view) {
    swipeRightOn(view, CGRectGetWidth([view bounds]) / 2);
}

RB_EXPORT void swipeUpOn(id view) {
    swipeUpOn(view, CGRectGetHeight([view bounds]) / 2);
}

RB_EXPORT void swipeDownOn(id view) {
    swipeDownOn(view, CGRectGetHeight([view bounds]) / 2);
}
