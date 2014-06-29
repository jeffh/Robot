#import "RBFunctions.h"
#import "RBAccessibility.h"
#import "RBTouch.h"
#import "NSObject+RBKVCUndefined.h"
#import "RBAnimation.h"

@interface NSObject (PrivateAPIs) // _UIAlertControllerShimPresenter
- (NSArray *)_currentFullScreenAlertPresenters;
@end


RB_EXPORT NSArray *allViews(void) {
    return allViews([NSPredicate predicateWithValue:YES]);
}

RB_EXPORT NSArray *allViews(NSPredicate *predicate) {
    NSMutableArray *viewsToSearch = [NSMutableArray array];
    UIWindow *modalWindow = [[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] window];
    if (modalWindow) {
        [viewsToSearch addObject:modalWindow];
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        [viewsToSearch addObject:keyWindow];
    }
    return allViews(predicate, viewsToSearch);
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

RB_EXPORT void tapOn(NSArray *views) {
    NSCAssert(views.count, @"No views where given to be tapped on");
    tapOn(views, ^CGPoint(UIView *view) {
        return view.center;
    });
}

RB_EXPORT void tapOn(id view, CGPoint pointRelativeToView) {
    NSCAssert(view, @"A view wasn't given to be tapped on");
    [RBAnimation disableAnimationsInBlock:^{
        [RBTouch tapOnView:view atPoint:pointRelativeToView];
    }];
}

RB_EXPORT void tapOn(NSArray *views, CGPoint (^pointForView)(UIView *view)) {
    NSCAssert(views.count, @"No views where given to be tapped on");
    for (UIView *view in views) {
        [RBAnimation disableAnimationsInBlock:^{
            [RBTouch tapOnView:view atPoint:pointForView(view)];
        }];
    }
}
