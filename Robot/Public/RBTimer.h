#import <UIKit/UIKit.h>


typedef BOOL(^RBWatchBlock)();


/*! Supports asynchronous values
 */
@interface RBTimer : NSObject

+ (instancetype)defaultTimer;
- (instancetype)initWithRunLoop:(NSRunLoop *)runLoop pollingInterval:(NSTimeInterval)pollInterval;
- (BOOL)waitForAtMostTime:(NSTimeInterval)maxTimeInterval block:(RBWatchBlock)block;
- (void)waitOrFailForName:(NSString *)name forAtMostTime:(NSTimeInterval)maxTimeInterval block:(RBWatchBlock)block;
- (void)waitForTime:(NSTimeInterval)time;

@end
