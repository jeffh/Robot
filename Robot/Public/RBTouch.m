#import "RBTouch.h"


@interface UITouch (PrivateAPIs)

- (void)setPhase:(UITouchPhase)phase;
- (void)setTimestamp:(CFAbsoluteTime)timestamp;
- (void)setTapCount:(NSUInteger)tapCount;
- (void)setIsTap:(BOOL)isTap;
- (void)setView:(UIView *)view;
- (void)setWindow:(UIWindow *)window;
- (void)_setIsFirstTouchForView:(BOOL)isFirstTouchForView;
- (void)_setLocationInWindow:(CGPoint)point resetPrevious:(BOOL)reset;

@end


@interface UITouchesEvent : UIEvent

- (void)_addTouch:(UITouch *)touch forDelayedDelivery:(BOOL)delayDelivery;

@end

@interface UIApplication (PrivateAPIs)

- (id)_touchesEvent;

@end


@implementation RBTouch

+ (instancetype)touchAtPoint:(CGPoint)point inWindow:(UIWindow *)window phase:(UITouchPhase)phase
{
    UIView *touchedView = [window hitTest:point withEvent:nil];
    RBTouch *touch = [[RBTouch alloc] initWithWindowPoint:point phase:phase inView:touchedView];
    [touch sendEvent];
    return touch;
}

+ (instancetype)touchAtPoint:(CGPoint)point inView:(UIView *)view phase:(UITouchPhase)phase
{
    CGPoint windowPoint = [view.window convertPoint:point fromView:view];
    return [self touchAtPoint:windowPoint inWindow:view.window phase:phase];
}

+ (void)tapAtPoint:(CGPoint)point inView:(UIView *)view
{
    RBTouch *touch = [self touchAtPoint:point inView:view phase:UITouchPhaseBegan];
    [touch updatePhase:UITouchPhaseEnded];
    [touch sendEvent];
}

- (id)initWithWindowPoint:(CGPoint)windowPoint phase:(UITouchPhase)phase inView:(UIView *)view {
    self = [super init];
    if (self) {
        [self setPhase:phase];
        [self setTimestamp:CFAbsoluteTimeGetCurrent()];
        [self setTapCount:1];
        [self setIsTap:YES];
        [self setView:view];
        [self setWindow:view.window];
        [self _setIsFirstTouchForView:YES];
        [self _setLocationInWindow:windowPoint resetPrevious:YES];
    }
    return self;
}

- (void)updatePhase:(UITouchPhase)phase
{
    [self setTimestamp:CFAbsoluteTimeGetCurrent()];
    [self setPhase:phase];
}

- (void)updateWindowPoint:(CGPoint)point inView:(UIView *)view
{
    [self setTimestamp:CFAbsoluteTimeGetCurrent()];
    [self setView:view];
    [self _setLocationInWindow:point resetPrevious:NO];
}

- (void)sendEvent
{
    UITouchesEvent *event = [[UIApplication sharedApplication] _touchesEvent];
    if (![[event allTouches] containsObject:self]) {
        [event _addTouch:self forDelayedDelivery:NO];
    }
    [self.window sendEvent:event];
}

@end
