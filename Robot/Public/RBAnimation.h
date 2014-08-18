#import <UIKit/UIKit.h>


/*! Manages animations in UIKit and CoreAnimation
 */
@interface RBAnimation : NSObject

/*! Temporarily disables animation and files all animation callbacks for both
 *  UIView and CoreAnimations.
 *
 *  @warning In order for animation delegates and callbacks to be executed, the main RunLoop
 *           is advanced multiples times. This makes it slow -- so avoid using this method
 *           if its not needed.
 */
+ (void)disableAnimationsInBlock:(void(^)())block;

@end
