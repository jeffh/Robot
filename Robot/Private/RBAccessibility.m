#import "RBAccessibility.h"
#import <objc/message.h>
#import "RBAnimation.h"

@class UIAlertController;

@interface UIView (PrivateAPIs)

- (void)layoutBelowIfNeeded;
- (NSString *)recursiveDescription;

@end

@interface _UIAlertManager : NSObject

+ (UIAlertView *)topMostAlert;
+ (void)removeFromStack:(id)arg1;
+ (void)hideAlertsForTermination;

@end

@interface UIAlertView (PrivateAPIs)
+ (UIWindow *)_alertWindow;
- (void)_removeAlertWindowOrShowAnOldAlert;
@end


@interface _UIAlertControllerShimPresenter : NSObject // iOS 8+
+ (NSArray *)_currentFullScreenAlertPresenters;
+ (void)_removePresenter:(id)presenter;
- (void)_presentAlertControllerAnimated:(BOOL)animated completion:(void(^)())block;
- (void)_dismissAlertControllerAnimated:(BOOL)animated completion:(void(^)())block;
- (UIAlertController *)alertController;
@end


@interface RBAccessibility ()

@property (nonatomic) BOOL shouldRaiseExceptions;

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
    return [self objectsSatisfyingPredicate:predicate
                                   inObject:view
                          recursiveSelector:@selector(subviews)];
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
    return [(id)NSClassFromString(@"UIWindow") keyWindow];
}

- (BOOL)isAlertShowing
{
    if (NSClassFromString(@"_UIAlertControllerShimPresenter")) { // iOS 8+
        UIWindow *window = [[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] window];
        return window != nil;
    } else {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        return [window isKindOfClass:NSClassFromString(@"_UIModalItemHostingWindow")] && [NSClassFromString(@"_UIAlertManager") topMostAlert];
    }
}

- (void)removeAllAlerts
{
    [RBAnimation disableAnimationsInBlock:^{
        id _UIAlertManager = (id)NSClassFromString(@"_UIAlertManager");
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
        [_UIAlertControllerShimPresenter _removePresenter:lastPresenter];
    }
}

#pragma mark - Private

- (NSArray *)viewsWithPredicate:(NSPredicate *)predicate inView:(UIView *)view
{
    return [self objectsSatisfyingPredicate:predicate
                                   inObject:view
                          recursiveSelector:@selector(subviews)];
}

- (id)objectsSatisfyingPredicate:(NSPredicate *)predicate
                        inObject:(id)object
               recursiveSelector:(SEL)selector
{
    NSMutableArray *filteredViews = [NSMutableArray array];
    if ([predicate evaluateWithObject:object]) {
        [filteredViews addObject:object];
    }
    id children = objc_msgSend(object, selector);
    for (id childObject in children) {
        NSArray *matches = [self objectsSatisfyingPredicate:predicate
                                                   inObject:childObject
                                          recursiveSelector:selector];
        [filteredViews addObjectsFromArray:matches];
    }
    return filteredViews;
}

@end
