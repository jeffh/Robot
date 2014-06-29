#import "RBAnimation.h"
#import "NSObject+RBSwizzle.h"

@implementation RBAnimation

+ (void)disableAnimationsInBlock:(void(^)())block
{
    // Disable UIView animations
    [UIView setAnimationsEnabled:NO];
    {
        // this UIView transaction will finish after all animation completion callbacks fire
        [UIView beginAnimations:@"com.jeffhui.robot.animationless" context:0];
        {
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(cycleRunLoop)];

            // Disable CoreAnimation
            [CATransaction begin];
            {
                [CATransaction setAnimationDuration:0];
                [CATransaction setDisableActions:YES];
                block();
            }
            [CATransaction commit];
        }
        [UIView commitAnimations];
    }
    [UIView setAnimationsEnabled:YES];

    // triggers animation callbacks
    [self cycleRunLoop];
}

+ (void)cycleRunLoop
{
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate date]];
//    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate date]];
//    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}

@end
