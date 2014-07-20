#import <UIKit/UIKit.h>


/*! A mutatable subclass of UITouch.
 *
 *  Touches are mutated as their state changes. So instead of creating new touches to send, the
 *  same instance is mutated, which is how iOS tracks active touches.
 *
 *  When states of touches change, you should update the same instance instead of creating new
 *  ones and call -[RBTouch sendEvent] to run through UIKit's event lifecycle for touch processing.
 *
 *  Its also important to always end a touch event, or else UIKit may randomly crash and fail.
 *  To end a touch event, update its phase to UITouchPhaseEnded, and call -[sendEvent].
 *
 *  Uses private APIs.
 */
@interface RBTouch : UITouch

/*! Creates an instance of RBTouch that begins on the given point on the window with the
 *  initial phase set to UITouchPhaseBegan.
 *
 *  @notice The view given is used to compute the absolute point to touch. It may not necessaily
 *          be the view touched. This can because either a super view absorbs or ignores the touch
 *          or the view is below another view.
 *
 *  Before the touch is returned, -[RBTouch sendEvent] is called.
 */
+ (instancetype)touchAtPoint:(CGPoint)point inWindow:(UIWindow *)window;

/*! Creates an instance of RBTouch that begins on the given point on the window with the
 *  initial phase set to UITouchPhaseBegan.
 *
 *  @notice The view given is used to compute the absolute point to touch. It may not necessaily
 *          be the view touched. This can because either a super view absorbs or ignores the touch
 *          or the view is below another view.
 *
 *  The point is relative to the given view's superview.
 *
 *  Before the touch is returned, -[RBTouch sendEvent] is called.
 *
 *  @param view The view that the point is related to. The point is in the view's superview coordinates.
 *              This view may not be the final view receiving the touch.
 *  @param point The point to initially touch. This is relative to the view's superview coordinates.
 */
+ (instancetype)touchOnView:(UIView *)view atPoint:(CGPoint)point;

/*! Creates touch events that simulates tapping on a given point on the window.
 *
 *  @notice The view given is used to compute the absolute point to touch. It may not necessaily
 *          be the view touched. This can because either a super view absorbs or ignores the touch
 *          or the view is below another view.
 *
 *  This call method will call the appropriate -[sendEvents] to simulate the touch up event.
 *  Since the touch is not generally useful and cannot be mutated, it is not returned.
 */
+ (void)tapOnView:(UIView *)view atPoint:(CGPoint)point;

/*! Creates a UITouch-compatible object that can be updated, unlike the read-only parent class.
 *  Unlike the claa methods on this class, this will not call sendEvent immediately.
 *
 *  @param windowPoint the point to touch relative to the window screen space.
 *  @param phase the current state of the touch.
 *  @param view the target view that the touch is interacting with.
 */
- (id)initWithWindowPoint:(CGPoint)windowPoint phase:(UITouchPhase)phase inView:(UIView *)view;

/*! Updates the touch phase and timestamp.
 */
- (void)updatePhase:(UITouchPhase)phase;

/*! Updates point, view, and timestamp.
 */
- (void)updateWindowPoint:(CGPoint)point inView:(UIView *)view;

/*! Updates the point relative to the touched view's superview.
 */
- (void)updateRelativePoint:(CGPoint)viewPoint;

/*! Propagates this event through the current application. This should be called everytime the
 *  touch changes (eg - touchUp, moves point, etc.).
 */
- (void)sendEvent;

@end
