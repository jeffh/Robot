#import <UIKit/UIKit.h>


/*! An easy hook into globally disable animations
 */
@interface RBAnimation : NSObject

+ (void)disableAnimations;
+ (void)enableAnimations;
+ (void)disableAnimationsInBlock:(void(^)())block;

@end
