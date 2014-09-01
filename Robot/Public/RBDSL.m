#import "RBDSL.h"
#import "RBAccessibility.h"
#import "RBTouch.h"
#import "NSObject+RBKVCUndefined.h"
#import "RBTimeLapse.h"


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
        [results sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
            CGRect frame1 = view1.frame;
            CGRect frame2 = view2.frame;
            NSComparisonResult result = [@(frame1.origin.y) compare:@(frame2.origin.y)];
            if (result == NSOrderedSame) {
                return [@(frame1.origin.x) compare:@(frame2.origin.x)];
            }
            return result;
        }];
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

RB_EXPORT UIView *RB_inViewController(UIViewController *viewController) {
    return viewController.view;
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

RB_EXPORT NSPredicate *RB_ofExactClass(NSString *className) {
    Class aClass = NSClassFromString(className);
    NSCAssert(aClass, @"Class was not found: %@", className);
    return RB_ofExactClass(aClass);
}

RB_EXPORT NSPredicate *RB_ofClass(Class aClass) {
    return RB_where(@"self isKindOfClass: %@", aClass);
}

RB_EXPORT NSPredicate *RB_ofClass(NSString *className) {
    Class aClass = NSClassFromString(className);
    NSCAssert(aClass, @"Class was not found: %@", className);
    return RB_ofClass(aClass);
}

RB_EXPORT NSPredicate *RB_withText(NSString *text) {
    return RB_where(@"text == %@", text);
}

RB_EXPORT NSPredicate *RB_withLabel(NSString *accessibilityLabel) {
    return RB_where(@"accessibilityLabel == %@ "
                    @"OR text == %@ "
                    @"OR placeholder == %@",
                    accessibilityLabel,
                    accessibilityLabel,
                    accessibilityLabel);
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

RB_EXPORT NSPredicate *RB_withImage(UIImage *image) {
    return RB_where(^BOOL(UIView *view) {
        UIImage *viewImage = [view valueForKey:@"image"];
        return viewImage && (
            [viewImage isEqual:image] || (
                CGSizeEqualToSize(viewImage.size, image.size) &&
                [UIImagePNGRepresentation(viewImage) isEqual:UIImagePNGRepresentation(image)]
            )
        );
    });
}

RB_EXPORT NSPredicate *RB_onScreen(BOOL isOnScreen) {
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
        BOOL onScreen = CGRectIntersectsRect(viewFrameInWindow, rootView.bounds) || CGRectContainsRect(rootView.bounds, viewFrameInWindow);
        return onScreen == isOnScreen;
    });
}

RB_EXPORT NSPredicate *RB_thatCanBeSeen(BOOL canBeSeen) {
    NSPredicate *nonZeroSize = RB_where(^BOOL(UIView *view) {
        return !CGSizeEqualToSize(CGRectStandardize(view.bounds).size, CGSizeZero);
    });
    NSPredicate *hasPixelToDraw = [NSCompoundPredicate orPredicateWithSubpredicates:@[RB_where(@"clipsToBounds == NO"),
                                                                                      nonZeroSize]];
    NSPredicate *isVisible = RB_withVisibility(YES);
    NSPredicate *nonZeroAlpha = where(@"alpha > 0");
    NSPredicate *canBeSeenPredicate = RB_includingSuperViews(RB_matching(isVisible, hasPixelToDraw, RB_onScreen(YES), nonZeroAlpha));
    if (!canBeSeen) {
        return [NSCompoundPredicate notPredicateWithSubpredicate:canBeSeenPredicate];
    } else {
        return canBeSeenPredicate;
    }
}

RB_EXPORT NSPredicate *RB_withParent(NSPredicate *predicateForParent) {
    return RB_where(@"self.superview != nil AND %@ evaluateWithObject: self.superview", predicateForParent);
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

RB_EXPORT void RB_tapOn(id view, CGPoint pointRelativeToSuperView) {
    [RBTimeLapse disableAnimationsInBlock:^{
        [RBTouch tapOnView:view atPoint:pointRelativeToSuperView];
    }];
}

RB_EXPORT void RB_touchAndMoveLinearlyOn(id view, CGPoint start, CGPoint end, NSUInteger numOfIntermediatePoints) {
    [RBTouch touchAndMoveOnView:view intermediatePoints:numOfIntermediatePoints startingPoint:start endingPoint:end endingPhase:UITouchPhaseEnded];
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
