#import <UIKit/UIKit.h>


/*! A mutatable variant of UITouch.
 *
 *  Touches are mutated as their state changes. So instead of creating new touches to send, they
 *  are mutated inline.
 *
 *  When states of touches change, you should update the same instance instead of creating new
 *  ones.
 */
@interface RBTouch : UITouch

+ (instancetype)touchAtPoint:(CGPoint)point inWindow:(UIWindow *)window phase:(UITouchPhase)phase;
+ (instancetype)touchOnView:(UIView *)view atPoint:(CGPoint)point phase:(UITouchPhase)phase;
+ (void)tapOnView:(UIView *)view atPoint:(CGPoint)point;

/*! Creates a UITouch-compatible object that can be updated, unlike the read-only parent class.
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

/*! Propagates this event through the current application.
 */
- (void)sendEvent;

@end
