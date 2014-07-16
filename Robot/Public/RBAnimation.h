#import <UIKit/UIKit.h>


@interface RBAnimation : NSObject

+ (void)swizzleOutAnimations;
+ (void)unswizzleAnimations;
+ (void)disableAnimationsInBlock:(void(^)())block;

@end
