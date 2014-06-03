#import "RBTouch.h"
#import "RBKeyboard.h"
#import "RBAnimation.h"


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

@interface UIInternalEvent : UIEvent

- (void)_setTimestamp:(NSTimeInterval)timestamp;

@end

@interface UITouchesEvent : UIInternalEvent

- (void)_addTouch:(UITouch *)touch forDelayedDelivery:(BOOL)delayDelivery;
- (void)_clearTouches;
- (void)_invalidateGestureRecognizerForWindowCache;

@end

@interface UIApplication (PrivateAPIs)

- (id)_touchesEvent;

@end

@interface UIWindow (PrivateAPIs)

- (void)_sendTouchesForEvent:(UIEvent *)event;
- (void)_createSystemGestureGateGestureRecognizerIfNeeded;

@end


@implementation RBTouch

+ (instancetype)touchAtPoint:(CGPoint)point inWindow:(UIWindow *)window phase:(UITouchPhase)phase
{
    UIView *touchedView = [window hitTest:point withEvent:nil];
    RBTouch *touch = [[RBTouch alloc] initWithWindowPoint:point phase:phase inView:touchedView];
    [touch sendEvent];
    return touch;
}

+ (instancetype)touchOnView:(UIView *)view atPoint:(CGPoint)point phase:(UITouchPhase)phase
{
    NSAssert(view.superview, @"Touched view does not have a superview. Needs to be under a visible UIWindow");
    NSAssert(view.window, @"Touch events require views to be under a visible UIWindow");
    CGPoint windowPoint = [view.window convertPoint:point fromView:view.superview];
    NSAssert([view.window hitTest:windowPoint withEvent:nil],
             @"Attempted to touch an untouchable view at screen point %@:\n"
             @"\t%@\n"
             @"\n"
             @"But instead got:\n"
             @"\t%@\n"
             @"\n"
             @"This can occur because:\n"
             @" - The view you're trying to touch is hidden\n"
             @" - The view you're trying to touch is not accepting touches (userInteraction disabled; disabled control, etc.)\n"
             @" - The UIWindow this view resides in is not the key window and visible; call [window makeKeyAndVisible]\n",
             NSStringFromCGPoint(windowPoint), view, [view.window hitTest:point withEvent:nil]);
    return [self touchAtPoint:windowPoint inWindow:view.window phase:phase];
}

+ (void)tapOnView:(UIView *)view atPoint:(CGPoint)point
{
    RBTouch *touch = [self touchOnView:view atPoint:(CGPoint)point phase:UITouchPhaseBegan];
    [touch updatePhase:UITouchPhaseEnded];
    [touch sendEvent];
}

- (id)initWithWindowPoint:(CGPoint)windowPoint phase:(UITouchPhase)phase inView:(UIView *)view
{
    NSAssert(view, @"A view is required to touch");
    NSAssert(view.window, @"Touch events require views to be under a visible UIWindow");
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
    [event _setTimestamp:CFAbsoluteTimeGetCurrent()];
    if (![[event allTouches] containsObject:self]) {
        [event _addTouch:self forDelayedDelivery:NO];
    }
    [self.window sendEvent:event];
}

@end
