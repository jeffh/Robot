#import "RBAnimation.h"
#import "NSObject+RBSwizzle.h"

@interface UIViewController (RBSwizzle)
- (void)original_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)original_dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;
@end

@interface UIViewController (RB)
+ (void)RB_attach;
- (void)RB_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
- (void)RB_dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion;
@end

@implementation UIViewController (RB)

+ (void)RB_attach
{
    [self RB_swizzleInstanceMethod:@selector(dismissViewControllerAnimated:completion:)
                       movingOldTo:@selector(original_dismissViewControllerAnimated:completion:)
                     replacingWith:@selector(RB_dismissViewControllerAnimated:completion:)];
}

+ (void)RB_detach
{
    [self RB_replaceInstanceMethod:@selector(dismissViewControllerAnimated:completion:)
                        withMethod:@selector(original_dismissViewControllerAnimated:completion:)];
}

- (void)RB_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [self original_presentViewController:viewControllerToPresent animated:NO completion:completion];
}

- (void)RB_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (![self valueForKey:@"currentAction"]) { // suppress warning.
        [self original_dismissViewControllerAnimated:NO completion:completion];
    }
}

@end


@implementation RBAnimation

+ (void)initialize
{
    [super initialize];
    [self swizzleOutAnimations];
}

+ (void)swizzleOutAnimations
{
    [UIViewController RB_attach];
}

+ (void)unswizzleAnimations
{
    [UIViewController RB_attach];
}

+ (void)disableAnimationsInBlock:(void(^)())block
{
    // Disable UIView animations
    [UIView performWithoutAnimation:^{
        // this UIView transaction will finish after all animation completion callbacks fire
        [UIView beginAnimations:@"net.jeffhui.robot.animationless" context:0];
        {
            [UIView setAnimationDuration:0];
            [UIView setAnimationDelay:0];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(cycleRunLoop)];

            // Disable CoreAnimation
            [CATransaction begin];
            {
                [CATransaction setCompletionBlock:^{
                    [self cycleRunLoop];
                }];
                [CATransaction setAnimationDuration:0];
                [CATransaction setDisableActions:YES];
                block();
            }
            [CATransaction commit];
        }
        [UIView commitAnimations];
    }];

    // triggers animation callbacks
    [self cycleRunLoop];
}

+ (void)cycleRunLoop
{
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
}

@end
