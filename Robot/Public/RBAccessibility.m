#import "RBAccessibility.h"
#import <objc/message.h>
#import "RBAnimation.h"

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
- (void)_dismissAlertControllerAnimated:(BOOL)animated completion:(void(^)())block;

- (/*UIAlertViewController*/UIViewController *)alertController;

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

+ (void)beforeEach
{
    CFPreferencesSetAppValue((CFStringRef)@"UIAutomationEnabled", kCFBooleanTrue, (CFStringRef)@"com.apple.UIAutomation");
    [NSClassFromString(@"_UIAlertManager") hideAlertsForTermination];
    [[self sharedInstance] cleanup];
}

- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicate:(NSPredicate *)predicate
{
    [view layoutIfNeeded];
    [view layoutBelowIfNeeded];
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

- (void)layoutView:(UIView *)view
{
    [view layoutBelowIfNeeded];
}

- (BOOL)isAlertViewShowing
{
    if (NSClassFromString(@"_UIAlertControllerShimPresenter")) { // iOS 8+
        return !![[[NSClassFromString(@"_UIAlertControllerShimPresenter") _currentFullScreenAlertPresenters] lastObject] window];
    } else {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        return [window isKindOfClass:NSClassFromString(@"_UIModalItemHostingWindow")] && [NSClassFromString(@"_UIAlertManager") topMostAlert];
    }
}

- (void)cleanup
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
        [[lastPresenter alertController] dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Private

- (NSArray *)viewsWithPredicate:(NSPredicate *)predicate inView:(UIView *)view
{
    return [self objectsSatisfyingPredicate:predicate
                                   inObject:view
                          recursiveSelector:@selector(subviews)];
}

- (id)objectsSatisfyingPredicate:(NSPredicate *)predicate inObject:(id)object recursiveSelector:(SEL)selector
{
    NSMutableArray *filteredViews = [NSMutableArray array];
    if ([predicate evaluateWithObject:object]) {
        [filteredViews addObject:object];
    }
    id children = objc_msgSend(object, selector);
    for (id childObject in children) {
        NSArray *matches = [self objectsSatisfyingPredicate:predicate inObject:childObject recursiveSelector:selector];
        [filteredViews addObjectsFromArray:matches];
    }
    return filteredViews;
}

@end
