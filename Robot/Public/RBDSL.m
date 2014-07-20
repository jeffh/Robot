#import "RBDSL.h"
#import "RBAccessibility.h"
#import "RBTouch.h"
#import "NSObject+RBKVCUndefined.h"
#import "RBAnimation.h"


#pragma mark - View Fetching

RB_EXPORT NSArray *RB_allViews(void) {
    return allViews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate) {
    return allViews(predicate, [[RBAccessibility sharedInstance] keyWindow]);
}

RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate, NSArray *viewsToSearch) {
    NSPredicate *ignoreNoisyViews = where(@"class != %@", NSClassFromString(@"_UIBackdropEffectView"));
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ignoreNoisyViews, predicate]];
    __block NSArray *results;
    [UIView RB_allowUndefinedKeysInBlock:^{
        results = [[RBAccessibility sharedInstance] subviewsOfViews:viewsToSearch
                                                satisfyingPredicate:predicate];
    }];
    return results;
}

RB_EXPORT NSArray *RB_allViews(NSPredicate *predicate, UIView *viewToSearch) {
    return RB_allViews(predicate, @[viewToSearch]);
}

RB_EXPORT NSArray *RB_allSubViews(void) {
    return RB_allSubViews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate) {
    return RB_allSubViews(predicate, [[RBAccessibility sharedInstance] keyWindow]);
}

RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate, NSArray *viewsToSearch) {
    NSPredicate *ignoreSelf = where(@"NOT SELF IN %@", viewsToSearch);
    NSPredicate *fullPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ignoreSelf, predicate]];
    return RB_allViews(fullPredicate, viewsToSearch);
}

RB_EXPORT NSArray *RB_allSubViews(NSPredicate *predicate, UIView *viewToSearch) {
    return RB_allSubViews(predicate, @[viewToSearch]);
}

RB_EXPORT id RB_theFirstView(void) {
    return RB_theFirstView([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT id RB_theFirstView(NSPredicate *predicate) {
    return [RB_allViews(predicate) firstObject];
}

RB_EXPORT id RB_theFirstView(NSPredicate *predicate, NSArray *viewsToSearch) {
    return [RB_allViews(predicate, viewsToSearch) firstObject];
}

RB_EXPORT id RB_theFirstView(NSPredicate *predicate, UIView *viewToSearch) {
    return [RB_allViews(predicate, viewToSearch) firstObject];
}

RB_EXPORT BOOL RB_isView(NSPredicate *predicate, UIView *view) {
    return [predicate evaluateWithObject:view];
}

RB_EXPORT BOOL RB_isAlertVisible(void) {
    return [[RBAccessibility sharedInstance] isAlertShowing];
}

#pragma mark - View Mutation

RB_EXPORT void RB_removeAllAlerts(void) {
    return [[RBAccessibility sharedInstance] removeAllAlerts];
}

#pragma mark - View Querying

RB_EXPORT NSPredicate *RB_includingSuperViews(NSPredicate *predicate) {
    return RB_where(^BOOL(UIView *view) {
        UIView *viewOrParent = view;
        while (viewOrParent) {
            if (![predicate evaluateWithObject:viewOrParent]) {
                return NO;
            }
            viewOrParent = viewOrParent.superview;
        }
        return YES;
    });
}

RB_EXPORT NSPredicate *_RB_matching(NSArray *predicates) {
    NSCAssert(predicates, @"Expected %@ to be an array of predicates", predicates);
    NSCAssert([[predicates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[NSPredicate class]];
    }]] count], @"Expected %@ to be an array of predicates", predicates);
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

RB_EXPORT NSPredicate *RB_ofExactClass(Class aClass) {
    return RB_where(@"class == %@", aClass);
}

RB_EXPORT NSPredicate *RB_ofClass(Class aClass) {
    return RB_where(@"self isKindOfClass: %@", aClass);
}

RB_EXPORT NSPredicate *RB_withLabel(NSString *accessibilityLabel) {
    return RB_where(@"accessibilityLabel == %@ OR text == %@",
                    accessibilityLabel, accessibilityLabel);
}

RB_EXPORT NSPredicate *RB_withTraits(UIAccessibilityTraits traits) {
    return RB_where(^BOOL(UIView *view) {
        return (view.accessibilityTraits & traits) == traits;
    });
}

RB_EXPORT NSPredicate *RB_withAccessibility(BOOL isAcessibilityView) {
    return RB_where(@"isAccessibilityElement == %@", isAcessibilityView);
}

RB_EXPORT NSPredicate *RB_withVisibility(BOOL isVisible) {
    return RB_where(@"hidden == %@", @(!isVisible));
}

RB_EXPORT NSPredicate *RB_onScreen(void) {
    return RB_where(^BOOL(UIView *view) {
        UIView *rootView = view.window;
        if (!rootView) {
            rootView = view;
            UIView *superView;
            while ((superView = rootView.superview)) {
                rootView = superView;
            }
        }
        CGRect viewFrameInWindow = [view.superview convertRect:view.frame toView:rootView];
        return CGRectIntersectsRect(viewFrameInWindow, rootView.bounds) || CGRectContainsRect(rootView.bounds, viewFrameInWindow);
    });
}

RB_EXPORT NSPredicate *RB_thatCanBeSeen(BOOL canBeSeen) {
    NSPredicate *nonZeroSize = RB_where(^BOOL(UIView *view) {
        return !CGSizeEqualToSize(CGRectStandardize(view.bounds).size, CGSizeZero);
    });
    NSPredicate *hasPixelToDraw = [NSCompoundPredicate orPredicateWithSubpredicates:@[RB_where(@"clipsToBounds == NO"),
                                                                                      nonZeroSize]];
    NSPredicate *isVisible = RB_withVisibility(YES);
    NSPredicate *canBeSeenPredicate = RB_includingSuperViews(RB_matching(isVisible, hasPixelToDraw, RB_onScreen()));
    if (!canBeSeen) {
        return [NSCompoundPredicate notPredicateWithSubpredicate:canBeSeenPredicate];
    } else {
        return canBeSeenPredicate;
    }
}

RB_EXPORT NSPredicate *RB_where(NSString *predicateFormat, ...) {
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

RB_EXPORT NSPredicate *RB_where(BOOL(^matcher)(UIView *view)) {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return matcher(evaluatedObject);
    }];
}

#pragma mark - View Interaction

RB_EXPORT void RB_tapOn(id view) {
    RB_tapOn(view, [view center]);
}

RB_EXPORT void RB_tapOn(id view, CGPoint pointRelativeToView) {
    NSCAssert(view, @"A view wasn't given to be tapped on");
    [RBAnimation disableAnimationsInBlock:^{
        [RBTouch tapOnView:view atPoint:pointRelativeToView];
    }];
}

RB_EXPORT void RB_touchAndMove(id view, CGPoint *points, NSUInteger numOfPoints) {
    NSCAssert(view, @"A view wasn't given to be tapped on");
    NSCAssert(numOfPoints, @"Expected at least 1 point");
    __block RBTouch *touch;
    [RBAnimation disableAnimationsInBlock:^{
        touch = [RBTouch touchOnView:view atPoint:points[0]];
    }];
    for (NSUInteger i = 1; i < numOfPoints; i++) {
        [touch updateRelativePoint:points[i]];
        [touch updatePhase:(i + 1 == numOfPoints ? UITouchPhaseEnded : UITouchPhaseMoved)];
        [touch sendEvent];
    }
}

RB_EXPORT void RB_touchAndMoveLinearlyOn(id view, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints) {
    NSUInteger numPoints = numOfIntermediatePoints + 2;
    CGPoint delta = CGPointMake((end.x - start.x) / numPoints,
                                (end.y - start.y) / numPoints);
    CGPoint *points = alloca(numPoints * sizeof(CGPoint));
    points[0] = start;
    for (NSUInteger i = 1; i < numPoints - 1; i++) {
        points[i] = CGPointMake(points[i-1].x + delta.x, points[i-1].y + delta.y);
    }
    points[numPoints - 1] = end;
    RB_touchAndMove(view, points, numPoints);
}

RB_EXPORT void RB_touchAndMoveLinearlyAroundPointOn(id view, CGPoint center, CGPoint delta, NSUInteger numOfIntermediatePoints) {
    CGPoint start = CGPointMake(center.x - delta.x, center.y - delta.y);
    CGPoint end = CGPointMake(center.x + delta.x, center.y + delta.y);
    RB_touchAndMoveLinearlyOn(view, start, end, numOfIntermediatePoints);
}

RB_EXPORT void RB_touchAndMoveLinearlyFromCenterOf(id view, CGPoint delta, NSUInteger numOfIntermediatePoints) {
    RB_touchAndMoveLinearlyAroundPointOn(view, [view center], delta, numOfIntermediatePoints);
}

const NSUInteger kRBDefaultNumberOfIntermediatePoints = 5;

RB_EXPORT void RB_swipeLeftOn(id view, CGFloat swipeWidth) {
    RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(-swipeWidth / 2, 0), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void RB_swipeRightOn(id view, CGFloat swipeWidth) {
    RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(swipeWidth / 2, 0), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void RB_swipeUpOn(id view, CGFloat swipeHeight) {
    RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, -swipeHeight / 2), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void RB_swipeDownOn(id view, CGFloat swipeHeight) {
    RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, swipeHeight), kRBDefaultNumberOfIntermediatePoints);
}

RB_EXPORT void RB_swipeLeftOn(id view) {
    RB_swipeLeftOn(view, CGRectGetWidth([view bounds]) / 2);
}

RB_EXPORT void RB_swipeRightOn(id view) {
    RB_swipeRightOn(view, CGRectGetWidth([view bounds]) / 2);
}

RB_EXPORT void RB_swipeUpOn(id view) {
    RB_swipeUpOn(view, CGRectGetHeight([view bounds]) / 2);
}

RB_EXPORT void RB_swipeDownOn(id view) {
    RB_swipeDownOn(view, CGRectGetHeight([view bounds]) / 2);
}
