#import <UIKit/UIKit.h>


/*! Manages animations in UIKit and CoreAnimation
 */
@interface RBAnimation : NSObject

/*! Swizzles out certain UIKit classes to disable animation.
 *
 *  Currently, only UIViewController's dismissViewController methods are swizzled.
 */
+ (void)swizzleOutAnimations;

/*! Unswizzles certain UIKit classes to re-enable animation.
 */
+ (void)unswizzleAnimations;

/*! Temporarily disables animation and files all animation callbacks for both
 *  UIView and CoreAnimations.
 *
 *  @warning In order for animation delegates and callbacks to be executed, the main RunLoop
 *           is advanced multiples times. This makes it slow -- so avoid using this method
 *           if its not needed.
 */
+ (void)disableAnimationsInBlock:(void(^)())block;

@end
