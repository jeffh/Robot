#import "RBTouch.h"
#import "RBTimeLapse.h"


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

@end

@interface UIApplication (PrivateAPIs)

- (id)_touchesEvent;

@end


@implementation RBTouch

+ (instancetype)touchAtPoint:(CGPoint)point
                    inWindow:(UIWindow *)window
                 atTimestamp:(CFAbsoluteTime)timestamp
{
    UIView *touchedView = [window hitTest:point withEvent:nil];
    RBTouch *touch = [[RBTouch alloc] initWithWindowPoint:point
                                                    phase:UITouchPhaseBegan
                                                   inView:touchedView
                                              atTimestamp:timestamp];
    [touch sendEvent];
    return touch;
}

+ (instancetype)touchOnView:(UIView *)view
                    atPoint:(CGPoint)point
                atTimestamp:(CFAbsoluteTime)timestamp
{
    NSAssert(view, @"Received a nil view. Needs to be a view inside a UIWindow.");
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
    RBTouch *touch = [self touchAtPoint:windowPoint inWindow:view.window atTimestamp:timestamp];
    return touch;
}

+ (void)tapOnView:(UIView *)view atPoint:(CGPoint)point
{
    RBTouch *touch = [self touchOnView:view
                               atPoint:(CGPoint)point
                           atTimestamp:CFAbsoluteTimeGetCurrent()];
    [touch updatePhase:UITouchPhaseEnded];
    [touch sendEvent];
}

+ (instancetype)touchAndMoveOnView:(UIView *)view
                    numberOfPoints:(NSUInteger)numberOfPoints
                       touchPoints:(CGPoint *)points
                       endingPhase:(UITouchPhase)endingPhase
{
    NSAssert(view, @"A view wasn't given to be tapped on");
    NSAssert(numberOfPoints, @"Expected at least 1 point");
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent() - numberOfPoints * 0.01;
    __block RBTouch *touch;
    [RBTimeLapse disableAnimationsInBlock:^{
        touch = [RBTouch touchOnView:view atPoint:points[0] atTimestamp:startTime];
    }];
    UIView *originalView = view;
    for (NSUInteger i = 1; i < numberOfPoints; i++) {
        [touch setView:originalView];
        [touch updateRelativePoint:points[i]];
        if (i + 1 == numberOfPoints) {
            [touch updatePhase:endingPhase];
        }
        else if (CGPointEqualToPoint(points[i-1], points[i])) {
            [touch updatePhase:UITouchPhaseStationary];
        }
        else {
            [touch updatePhase:UITouchPhaseMoved];
        }
        [touch setTimestamp:CFAbsoluteTimeGetCurrent()];
        [RBTimeLapse disableAnimationsInBlock:^{
            [touch sendEvent];
        }];
    }
    return touch;
}

+ (instancetype)touchAndMoveOnView:(UIView *)view
                intermediatePoints:(NSUInteger)numberOfIntermediatePoints
                     startingPoint:(CGPoint)startingPoint
                       endingPoint:(CGPoint)endingPoint
                       endingPhase:(UITouchPhase)endingPhase
{
    NSUInteger numberOfPoints = numberOfIntermediatePoints + 2;
    CGPoint delta = CGPointMake((endingPoint.x - startingPoint.x) / numberOfPoints,
                                (endingPoint.y - startingPoint.y) / numberOfPoints);
    CGPoint *points = alloca(numberOfPoints * sizeof(CGPoint));
    points[0] = startingPoint;
    for (NSUInteger i = 1; i < numberOfPoints - 1; i++) {
        points[i] = CGPointMake(points[i-1].x + delta.x, points[i-1].y + delta.y);
    }
    points[numberOfPoints - 1] = endingPoint;
    return [self touchAndMoveOnView:view
                     numberOfPoints:numberOfPoints
                        touchPoints:points
                        endingPhase:endingPhase];
}

- (id)initWithWindowPoint:(CGPoint)windowPoint
                    phase:(UITouchPhase)phase
                   inView:(UIView *)view
              atTimestamp:(CFAbsoluteTime)timestamp
{
    NSAssert(view, @"A view is required to touch");
    NSAssert(view.window, @"Touch events require views to be under a visible UIWindow");
    self = [super init];
    if (self) {
        [self setPhase:phase];
        [self setTimestamp:timestamp];
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

- (void)updateRelativePoint:(CGPoint)viewPoint
{
    CGPoint windowPoint = [self.window convertPoint:viewPoint fromView:self.view.superview];
    UIView *touchedView = [self.window hitTest:windowPoint withEvent:nil];
    [self updateWindowPoint:windowPoint inView:touchedView];
}

- (void)sendEvent
{
    UITouchesEvent *event = [[UIApplication sharedApplication] _touchesEvent];
    [event _setTimestamp:[self timestamp]];
    if (![[event allTouches] containsObject:self]) {
        [event _addTouch:self forDelayedDelivery:NO];
    }
    [self.window sendEvent:event];
}

@end
