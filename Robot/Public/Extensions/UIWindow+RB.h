#import <UIKit/UIKit.h>

@interface UIWindow (RB)

/*! Creates a new window with the frame matching the size of the screen.
 *
 *  Calling this method will return a new instance each time.
 */
+ (instancetype)createWindowForTesting;

@end
