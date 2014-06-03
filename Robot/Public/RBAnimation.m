#import "RBAnimation.h"
#import "NSObject+RBSwizzle.h"

@interface UIAlertView (PrivateAPIs)
- (void)popupAlertAnimated:(BOOL)animated animationType:(int)type atOffset:(CGFloat)offset;
- (void)_performPopoutAnimationAnimated:(BOOL)animated coveredBySpringBoardAlert:(BOOL)covered;
@end

@interface UIView (RBAnimation)
+ (BOOL)RB_areAnimationsEnabled;
@end

@interface UIView (RBAnimation_Swizzle)
+ (BOOL)RB_originalAreAnimationsEnabled;
@end

@implementation UIView (RBAnimation)

+ (BOOL)RB_areAnimationsEnabled
{
    return NO;
}

@end

@implementation RBAnimation

static BOOL RBWasSwizzled;

+ (void)disableAnimations
{
    [UIAlertView setAnimationsEnabled:NO];
    [UIView setAnimationsEnabled:NO];
    [self attach];
}

+ (void)enableAnimations
{
    [self detach];
    [UIView setAnimationsEnabled:YES];
    [UIAlertView setAnimationsEnabled:YES];
}

+ (void)attach
{
    if (!RBWasSwizzled) {
        [UIView RB_swizzleClassMethod:@selector(areAnimationsEnabled)
                          movingOldTo:@selector(RB_originalAreAnimationsEnabled)
                        replacingWith:@selector(RB_areAnimationsEnabled)];
        [CATransaction setDisableActions:YES];

        RBWasSwizzled = YES;
    }
}

+ (void)detach
{
    if (RBWasSwizzled) {
        [UIView RB_replaceClassMethod:@selector(areAnimationsEnabled)
                           withMethod:@selector(RB_originalAreAnimationsEnabled)];
        RBWasSwizzled = NO;
    }
}

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
    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate date]];
    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}

@end
