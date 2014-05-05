#import <Foundation/Foundation.h>


/*! An easy hook into globally disable animations
 */
@interface RBAnimation : NSObject

+ (void)disableAnimations;
+ (void)enableAnimations;

@end
