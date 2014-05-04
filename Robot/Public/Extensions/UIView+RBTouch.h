#import <UIKit/UIKit.h>


@interface UIView (RBTouch)

/*! Taps on the center of a view.
 */
- (void)tap;

/*! Taps on a point of a view.
 *
 *  @param point The point relative to the view's parent view to tap on.
 */
- (void)tapAtPoint:(CGPoint)point;

@end
