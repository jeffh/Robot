#import "RBAccessibility.h"
#import <objc/message.h>
#import "RBTimer.h"


@interface UIView (PrivateAPIs)

- (void)layoutBelowIfNeeded;

@end

@interface _UIAlertManager : NSObject

+ (UIAlertView *)visibleAlert;

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

- (instancetype)initAndRaiseExceptionsIfCannotFindObjects:(BOOL)shouldRaiseExceptions
{
    self = [super init];
    self.shouldRaiseExceptions = shouldRaiseExceptions;
    return self;
}

- (instancetype)init
{
    return [self initAndRaiseExceptionsIfCannotFindObjects:YES];
}

- (UINavigationController *)findNavigationControllerInViewController:(UIViewController *)rootViewController
{
    NSArray *controllers = [self objectsSatisfyingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UINavigationController class]]
                                                   inObject:rootViewController
                                          recursiveSelector:@selector(childViewControllers)];
    [self raiseException:NSInvalidArgumentException
                  reason:@"Could not find view controller with navigation controller"
               ifNoMatch:controllers.count];
    return (UINavigationController *)[controllers firstObject];
}

- (UINavigationBar *)findNavigationBarInViewController:(UIViewController *)rootViewController
{
    return [[self findNavigationControllerInViewController:rootViewController] navigationBar];
}

- (NSArray *)subviewsInView:(UIView *)view withIdentifier:(NSString *)accessibilityIdentifier
{
    return [self subviewsInView:view satisfyingPredicate:[NSPredicate predicateWithFormat:@"accessibilityIdentifier = %@", accessibilityIdentifier]];
}

- (NSArray *)subviewsInView:(UIView *)view withLabel:(NSString *)accessibilityLabel
{
    return [self subviewsInView:view satisfyingPredicate:[NSPredicate predicateWithFormat:@"accessibilityLabel = %@", accessibilityLabel]];
}

- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicateFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSArray *views = [self subviewsInView:view satisfyingPredicateFormat:format arguments:args];
    va_end(args);
    return views;
}

- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicateFormat:(NSString *)format arguments:(va_list)arguments
{
    return [self viewsWithPredicate:[NSPredicate predicateWithFormat:format arguments:arguments] inView:view];
}

- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicate:(NSPredicate *)predicate
{
    NSArray *views = [self objectsSatisfyingPredicate:predicate
                                             inObject:view
                                    recursiveSelector:@selector(subviews)];
    [self raiseException:NSInvalidArgumentException
                  reason:[NSString stringWithFormat:@"Could not find views with predicate: %@", predicate]
               ifNoMatch:views.count];
    return views;
}

- (void)layoutView:(UIView *)view
{
    [view layoutBelowIfNeeded];
}

- (UIAlertView *)visibleAlertView
{
    return [NSClassFromString(@"_UIAlertManager") visibleAlert];
}

#pragma mark - Private

- (void)raiseException:(NSString *)exceptionName reason:(NSString *)reason ifNoMatch:(BOOL)hasMatch
{
    if (self.shouldRaiseExceptions && !hasMatch) {
        @throw [NSException exceptionWithName:exceptionName reason:reason userInfo:nil];
    }
}

- (NSArray *)viewsWithPredicate:(NSPredicate *)predicate inView:(UIView *)view
{
    NSArray *views = [self objectsSatisfyingPredicate:predicate
                                             inObject:view
                                    recursiveSelector:@selector(subviews)];
    [self raiseException:NSInvalidArgumentException
                  reason:[NSString stringWithFormat:@"Could not find views with predicate: %@", predicate]
               ifNoMatch:views.count];
    return views;
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
