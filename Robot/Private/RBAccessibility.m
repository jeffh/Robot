#import "RBAccessibility.h"
#import <objc/message.h>


@interface RBAccessibility ()

@property (nonatomic) UIWindow *window;
@property (nonatomic) BOOL shouldRaiseExceptions;

@end


@implementation RBAccessibility

- (instancetype)initWithWindow:(UIWindow *)window raiseExceptionsIfCannotFindObjects:(BOOL)shouldRaiseExceptions
{
    self = [super init];
    self.window = window;
    self.shouldRaiseExceptions = shouldRaiseExceptions;
    return self;
}

- (UINavigationController *)rootNavigationController
{
    UIViewController *controller = [self objectSatisfyingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UINavigationController class]]
                                                          inObject:[self.window rootViewController]
                                                 recursiveSelector:@selector(childViewControllers)];
    [self raiseException:NSInvalidArgumentException
                  reason:@"Could not find view controller with navigation controller"
           ifObjectIsNil:controller];
    return (UINavigationController *)controller;
}

- (UINavigationBar *)rootNavigationBar
{
    return [self rootNavigationController].navigationBar;
}

- (id)viewWithIdentifier:(NSString *)accessibilityIdentifier
{
    NSPredicate *accessibilityIdentifierPredicate = [NSPredicate predicateWithFormat:@"accessibilityIdentifier = %@", accessibilityIdentifier];
    UIView *view = [self objectSatisfyingPredicate:accessibilityIdentifierPredicate
                                          inObject:self.window
                                 recursiveSelector:@selector(subviews)];
    [self raiseException:NSInvalidArgumentException
                  reason:[NSString stringWithFormat:@"Could not find view with accessibility label: %@", accessibilityIdentifier]
           ifObjectIsNil:view];
    return view;
}

- (id)viewWithLabel:(NSString *)accessibilityLabel
{
    NSPredicate *accessibilityLabelPredicate = [NSPredicate predicateWithFormat:@"accessibilityLabel = %@", accessibilityLabel];
    UIView *view = [self objectSatisfyingPredicate:accessibilityLabelPredicate
                                          inObject:self.window
                                 recursiveSelector:@selector(subviews)];
    [self raiseException:NSInvalidArgumentException
                  reason:[NSString stringWithFormat:@"Could not find view with accessibility label: %@", accessibilityLabel]
           ifObjectIsNil:view];
    return view;
}

#pragma mark - Private

- (void)raiseException:(NSString *)exceptionName reason:(NSString *)reason ifObjectIsNil:(id)object
{
    if (self.shouldRaiseExceptions && !object) {
        @throw [NSException exceptionWithName:exceptionName reason:reason userInfo:nil];
    }
}

- (id)objectSatisfyingPredicate:(NSPredicate *)predicate inObject:(id)object recursiveSelector:(SEL)selector
{
    if ([predicate evaluateWithObject:object]) {
        return object;
    } else {
        id children = objc_msgSend(object, selector);
        for (id childObject in children) {
            id matchingObject = [self objectSatisfyingPredicate:predicate inObject:childObject recursiveSelector:selector];
            if (matchingObject) {
                return matchingObject;
            }
        }
        return nil;
    }
}
@end
