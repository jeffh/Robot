#import "RBDriver.h"
#import "RBAccessibility.h"
#import "RBTimer.h"
#import "RBKeyboard.h"
#import "RBAnimation.h"
#import "RBTouch.h"


@interface RBDriver ()

@property (nonatomic) UIWindow *window;
@property (nonatomic) RBAccessibility *accessibility;
@property (nonatomic) RBTimer *timer;
@property (nonatomic) RBKeyboard *keyboard;
@property (nonatomic, getter = areAnimationsDisabled) BOOL animationsDisabled;

@end


@implementation RBDriver

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithWindow:(UIWindow *)window
             disableAnimations:(BOOL)disableAnimations
               pollingInterval:(NSTimeInterval)pollInterval
     raiseExceptionsIfNotFound:(BOOL)raiseExceptionsIfNotFound
{
    self = [super init];
    self.window = window;
    self.animationsDisabled = disableAnimations;
    self.accessibility = [[RBAccessibility alloc] initWithWindow:window raiseExceptionsIfCannotFindObjects:raiseExceptionsIfNotFound];
    self.timer = [[RBTimer alloc] initWithRunLoop:[NSRunLoop mainRunLoop] pollingInterval:pollInterval];
    self.keyboard = [[RBKeyboard alloc] initWithTimer:self.timer];
    return self;
}

#pragma mark - Public

- (void)setup
{
    [self.window makeKeyAndVisible];
    if (self.animationsDisabled) {
        [RBAnimation disableAnimations];
    }
}

- (void)teardown
{
    [self.window removeFromSuperview];
    if (self.animationsDisabled) {
        [RBAnimation enableAnimations];
    }
}

- (void)setViewController:(UIViewController *)viewController
{
    self.window.rootViewController = viewController;
}

- (UIViewController *)viewController
{
    return self.window.rootViewController;
}

#pragma mark - Facade

- (id)viewWithAccessibilityLabel:(NSString *)label
{
    return [self.accessibility viewWithLabel:label];
}

- (id)viewWithAccessibilityIdentifier:(NSString *)identifier
{
    return [self.accessibility viewWithIdentifier:identifier];
}

- (void)typeKey:(NSString *)key
{
    [self.keyboard typeKey:key instantly:!self.areKeyboardAnimationsEnabled];
}

- (void)typeString:(NSString *)string
{
    [self.keyboard typeString:string instantly:!self.areKeyboardAnimationsEnabled];
}

- (void)typeKeys:(NSArray *)keys
{
    [self.keyboard typeKeys:keys instantly:!self.areKeyboardAnimationsEnabled];
}

- (RBTouch *)touchAtPoint:(CGPoint)point inView:(UIView *)view phase:(UITouchPhase)phase
{
    return [RBTouch touchAtPoint:point inView:view phase:phase];
}

- (void)tapAtPoint:(CGPoint)point inView:(UIView *)view
{
    [RBTouch tapAtPoint:point inView:view];
}

- (UINavigationController *)rootNavigationController
{
    return [self.accessibility rootNavigationController];
}

- (UINavigationBar *)rootNavigationBar
{
    return [self.accessibility rootNavigationBar];
}

@end
