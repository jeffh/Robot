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
    return [[UIApplication sharedApplication].keyWindow isKindOfClass:NSClassFromString(@"_UIModalItemHostingWindow")];
}

- (void)cleanup
{
    id _UIAlertManager = (id)NSClassFromString(@"_UIAlertManager");
    UIAlertView *alertView;
    while ((alertView = [_UIAlertManager topMostAlert])) {
        alertView.delegate = nil; // should we be doing this or warning users?
        [_UIAlertManager removeFromStack:alertView];
    }
    [[_UIAlertManager topMostAlert] _removeAlertWindowOrShowAnOldAlert];
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
