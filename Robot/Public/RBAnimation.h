#import <UIKit/UIKit.h>


@interface RBAnimation : NSObject

+ (void)disableAnimationsInBlock:(void(^)())block;

@end
