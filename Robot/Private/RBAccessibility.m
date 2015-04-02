#import "RBAccessibility.h"
#import <objc/message.h>
#import "RBTimeLapse.h"


@interface UIView (PrivateAPIs)

- (void)layoutBelowIfNeeded;

@end

@interface _UIAlertManager : NSObject

+ (UIAlertView *)topMostAlert;
+ (void)removeFromStack:(id)arg1;

@end

@interface UIAlertView (PrivateAPIs)
+ (UIWindow *)_alertWindow;
- (void)_removeAlertWindowOrShowAnOldAlert;
@end


@interface _UIAlertControllerShimPresenter : NSObject // iOS 8+
+ (NSArray *)_currentFullScreenAlertPresenters;
+ (void)_removePresenter:(id)presenter;
- (id)alertController;
@end


@implementation RBAccessibility

+ (instancetype)sharedInstance
{
    static RBAccessibility *RBAccessbility__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RBAccessbility__ = [[self alloc] init];
    });
    return RBAccessbility__;
}

- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicate:(NSPredicate *)predicate
{
    // triggers -layoutIfNeeded: for the view and its recursive subviews.
    // this will implicitly trigger UITableViews and UICollectionViews to layout.
    [view layoutBelowIfNeeded];
    return [self objectsSatisfyingPredicate:predicate
                                   inObject:view
                          recursiveSelector:@selector(subviews)
                      substitutionVariables:@{@"rootView": view}];
}

- (NSArray *)subviewsOfViews:(NSArray *)views satisfyingPredicate:(NSPredicate *)predicate
{
    NSMutableArray *matchedViews = [NSMutableArray array];
    for (UIWindow *view in views) {
        [matchedViews addObjectsFromArray:[self subviewsInView:view satisfyingPredicate:predicate]];
    }
    return matchedViews;
}

- (NSArray *)windows
{
    NSMutableArray *viewsToSearch = [NSMutableArray array];
    UIWindow *modalWindow = [[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] window];
    if (modalWindow) {
        [viewsToSearch addObject:modalWindow];
    }
    [viewsToSearch addObjectsFromArray:[UIApplication sharedApplication].windows];
    return viewsToSearch;
}

- (UIWindow *)keyWindow
{
    return [(id)NSClassFromString(@"UIWindow") keyWindow] ?: [UIApplication sharedApplication].keyWindow;
}

- (BOOL)isAlertShowing
{
    if (NSClassFromString(@"_UIAlertControllerShimPresenter")) { // iOS 8+
        UIWindow *window1 = [[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] window];
        UIWindow *window2 = [[[[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] alertController] view] window];
        return window2 && window1;
    } else {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        return [window isKindOfClass:NSClassFromString(@"_UIModalItemHostingWindow")] && [NSClassFromString(@"_UIAlertManager") topMostAlert];
    }
}

- (void)removeAllAlerts
{
    [RBTimeLapse disableAnimationsInBlock:^{
        id _UIAlertManager = (id) NSClassFromString(@"_UIAlertManager");
        UIAlertView *alertView;
        while ((alertView = [_UIAlertManager topMostAlert])) {
            alertView.delegate = nil; // should we be doing this or warning users?
            [_UIAlertManager removeFromStack:alertView];
        }
        [[_UIAlertManager topMostAlert] _removeAlertWindowOrShowAnOldAlert];
    }];

    id _UIAlertControllerShimPresenter = (id)NSClassFromString(@"_UIAlertControllerShimPresenter");
    while ([_UIAlertControllerShimPresenter _currentFullScreenAlertPresenters].count) {
        id lastPresenter = [[_UIAlertControllerShimPresenter _currentFullScreenAlertPresenters] lastObject];
        [RBTimeLapse disableAnimationsInBlock:^{
            [_UIAlertControllerShimPresenter _removePresenter:lastPresenter];
        }];
    }
}

#pragma mark - Private

- (id)objectsSatisfyingPredicate:(NSPredicate *)predicate
                        inObject:(id)object
               recursiveSelector:(SEL)selector
           substitutionVariables:(NSDictionary *)substitutionVariables
{
    NSMutableArray *filteredViews = [NSMutableArray array];
    if ([predicate evaluateWithObject:object substitutionVariables:substitutionVariables]) {
        [filteredViews addObject:object];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id children = [object performSelector:selector withObject:nil];
#pragma clang diagnostic pop
    for (id childObject in children) {
        NSArray *matches = [self objectsSatisfyingPredicate:predicate
                                                   inObject:childObject
                                          recursiveSelector:selector
                                      substitutionVariables:substitutionVariables];
        [filteredViews addObjectsFromArray:matches];
    }
    return filteredViews;
}

@end
