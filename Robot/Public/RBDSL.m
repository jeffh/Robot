#import "RBDSL.h"
#import "RBAccessibility.h"
#import "RBTouch.h"
#import "NSObject+RBKVCUndefined.h"
#import "RBTimeLapse.h"
#import "RBViewQuery.h"
#import "RBUtils.h"


#pragma mark - View Fetching

RB_EXPORT_OVERLOADED RBViewQuery *RB_allViews(void) {
    return allViews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_allViews(NSPredicate *predicate) {
    // _UIBackdropEffectView emits warnings with walked over. Ignore it.
    NSPredicate *ignoreNoisyViews = where(@"class != %@", NSClassFromString(@"_UIBackdropEffectView"));
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ignoreNoisyViews, predicate]];
    NSArray *windows = [NSArray arrayWithObjects:[[RBAccessibility sharedInstance] keyWindow], nil];
    return [[RBViewQuery alloc] initWithMatchingPredicate:predicate
                                              inRootViews:windows
                                          sortDescriptors:@[]];
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_allViews(NSArray *predicates) {
    return RB_allViews([NSCompoundPredicate andPredicateWithSubpredicates:predicates]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_allSubviews(void) {
    return allSubviews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_allSubviews(NSPredicate *predicate) {
    return allViews(@[predicate, RB_withoutRootView()]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_allSubviews(NSArray *predicates) {
    return RB_allSubviews([NSCompoundPredicate andPredicateWithSubpredicates:predicates]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstView(void) {
    return RB_allViews().subrange(NSMakeRange(0, 1));
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstView(NSPredicate *predicate) {
    return RB_allViews(predicate).subrange(NSMakeRange(0, 1));
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstView(NSArray *predicates) {
    return RB_allViews(predicates).subrange(NSMakeRange(0, 1));
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstSubview(void) {
    return RB_theFirstSubview([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstSubview(NSPredicate *predicate) {
    return RB_theFirstSubview(@[predicate]);
}

RB_EXPORT_OVERLOADED RBViewQuery *RB_theFirstSubview(NSArray *predicates) {
    predicates = [predicates arrayByAddingObject:RB_withoutRootView()];
    return RB_theFirstSubview([NSCompoundPredicate andPredicateWithSubpredicates:predicates]);
}

RB_EXPORT BOOL RB_isAlertVisible(void) {
    return [[RBAccessibility sharedInstance] isAlertShowing];
}

#pragma mark - View Mutation

RB_EXPORT void RB_removeAllAlerts(void) {
    return [[RBAccessibility sharedInstance] removeAllAlerts];
}

#pragma mark - Sort Descriptors

RB_EXPORT NSSortDescriptor *RB_smallestOrigin(void) {
    return [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        CGRect frame1 = view1.frame;
        CGRect frame2 = view2.frame;
        NSComparisonResult result = [@(frame1.origin.y) compare:@(frame2.origin.y)];
        if (result == NSOrderedSame) {
            return [@(frame1.origin.x) compare:@(frame2.origin.x)];
        }
        return result;
    }];
}

RB_EXPORT NSSortDescriptor *RB_largestOrigin(void) {
    return [RB_smallestOrigin() reversedSortDescriptor];
}

RB_EXPORT NSSortDescriptor *RB_smallestSize(void) {
    return [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        CGRect frame1 = view1.frame;
        CGRect frame2 = view2.frame;
        NSComparisonResult result = [@(frame1.size.height) compare:@(frame2.size.height)];
        if (result == NSOrderedSame) {
            return [@(frame1.size.width) compare:@(frame2.size.width)];
        }
        return result;
    }];
}

RB_EXPORT NSSortDescriptor *RB_largestSize(void) {
    return [RB_smallestSize() reversedSortDescriptor];
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

RB_EXPORT_OVERLOADED NSPredicate *RB_ofExactClass(Class aClass) {
    return RB_where(@"class == %@", aClass);
}

RB_EXPORT_OVERLOADED NSPredicate *RB_ofExactClass(NSString *className) {
    Class aClass = NSClassFromString(className);
    NSCAssert(aClass, @"Class was not found: %@", className);
    return RB_ofExactClass(aClass);
}

RB_EXPORT_OVERLOADED NSPredicate *RB_ofClass(Class aClass) {
    return RB_where(@"self isKindOfClass: %@", aClass);
}

RB_EXPORT_OVERLOADED NSPredicate *RB_ofClass(NSString *className) {
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
    NSPredicate *visible = RB_where(@"hidden == %@", @(!isVisible));
    NSPredicate *nonZeroSize = RB_where(^BOOL(UIView *view) {
        return !CGSizeEqualToSize(CGRectStandardize(view.bounds).size, CGSizeZero);
    });
    NSPredicate *hasPixelToDraw = [NSCompoundPredicate orPredicateWithSubpredicates:@[RB_where(@"clipsToBounds == NO"), nonZeroSize]];
    NSPredicate *nonZeroAlpha = where(@"alpha > 0");
    return RB_matching(visible, hasPixelToDraw, nonZeroAlpha);
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
        BOOL onScreen = CGRectIntersectsRect(viewFrameInWindow, rootView.bounds)
                     || CGRectContainsRect(rootView.bounds, viewFrameInWindow);
        return onScreen == isOnScreen;
    });
}

RB_EXPORT NSPredicate *RB_onScreenAndVisible(BOOL canBeSeen) {
    NSPredicate *canBeSeenPredicate = RB_includingSuperViews(RB_matching(RB_withVisibility(YES), RB_onScreen(YES)));
    if (!canBeSeen) {
        return [NSCompoundPredicate notPredicateWithSubpredicate:canBeSeenPredicate];
    } else {
        return canBeSeenPredicate;
    }
}

RB_EXPORT NSPredicate *RB_withParent(NSPredicate *predicateForParent) {
    return RB_where(@"self.superview != nil AND %@ evaluateWithObject: self.superview",
                    predicateForParent);
}

RB_EXPORT NSPredicate *RB_withoutRootView(void) {
    return RB_where(@"self != $rootView");
}

RB_EXPORT_OVERLOADED NSPredicate *RB_where(NSString *predicateFormat, ...) {
    va_list args;
    va_start(args, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:args];
    va_end(args);
    return predicate;
}

RB_EXPORT_OVERLOADED NSPredicate *RB_where(BOOL(^matcher)(UIView *view)) {
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return matcher(evaluatedObject);
    }];
}

#pragma mark - View Interaction

RB_EXPORT_OVERLOADED void RB_tapOn(id viewOrViews) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        [RBTimeLapse disableAnimationsInBlock:^{
            [RBTouch tapOnView:view atPoint:[view center]];
        }];
    }
}

RB_EXPORT_OVERLOADED void RB_tapOn(id viewOrViews, CGPoint pointRelativeToSuperView) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        [RBTimeLapse disableAnimationsInBlock:^{
            [RBTouch tapOnView:view atPoint:pointRelativeToSuperView];
        }];
    }
}

RB_EXPORT void RB_touchAndMoveLinearlyOn(id viewOrViews,
                                         CGPoint start, CGPoint end,
                                         NSUInteger numOfIntermediatePoints) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        [RBTouch touchAndMoveOnView:view
                 intermediatePoints:numOfIntermediatePoints
                      startingPoint:start
                        endingPoint:end
                        endingPhase:UITouchPhaseEnded];
    }
}

RB_EXPORT void RB_touchAndMoveLinearlyAroundPointOn(id viewOrViews,
                                                    CGPoint center, CGPoint delta,
                                                    NSUInteger numOfIntermediatePoints) {
    CGPoint start = CGPointMake(center.x - delta.x, center.y - delta.y);
    CGPoint end = CGPointMake(center.x + delta.x, center.y + delta.y);
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyOn(view, start, end, numOfIntermediatePoints);
    }
}

RB_EXPORT void RB_touchAndMoveLinearlyFromCenterOf(id viewOrViews, CGPoint delta,
                                                   NSUInteger numOfIntermediatePoints) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyAroundPointOn(view,
                                             [view center], delta,
                                             numOfIntermediatePoints);
    }
}

const NSUInteger kRBDefaultNumberOfIntermediatePoints = 5;

RB_EXPORT_OVERLOADED void RB_swipeLeftOn(id viewOrViews, CGFloat swipeWidth) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(-swipeWidth / 2, 0),
                                            kRBDefaultNumberOfIntermediatePoints);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeRightOn(id viewOrViews, CGFloat swipeWidth) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(swipeWidth / 2, 0),
                                            kRBDefaultNumberOfIntermediatePoints);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeUpOn(id viewOrViews, CGFloat swipeHeight) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, -swipeHeight / 2),
                                            kRBDefaultNumberOfIntermediatePoints);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeDownOn(id viewOrViews, CGFloat swipeHeight) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_touchAndMoveLinearlyFromCenterOf(view, CGPointMake(0, swipeHeight),
                                            kRBDefaultNumberOfIntermediatePoints);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeLeftOn(id viewOrViews) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_swipeLeftOn(view, CGRectGetWidth([view bounds]) / 4);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeRightOn(id viewOrViews) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_swipeRightOn(view, CGRectGetWidth([view bounds]) / 4);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeUpOn(id viewOrViews) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_swipeUpOn(view, CGRectGetHeight([view bounds]) / 4);
    }
}

RB_EXPORT_OVERLOADED void RB_swipeDownOn(id viewOrViews) {
    for (UIView *view in RBForceIntoNonEmptyArray(viewOrViews)) {
        RB_swipeDownOn(view, CGRectGetHeight([view bounds]) / 4);
    }
}
