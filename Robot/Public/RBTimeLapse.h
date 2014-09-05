#import <UIKit/UIKit.h>
#import "RBMacros.h"


/*! Manipulates time-based operations to run without delay.
 */
RB_USES_PRIVATE_APIS
@interface RBTimeLapse : NSObject

/*! Temporarily disables animation and fires all animation callbacks for both
 *  UIView and CoreAnimations.
 *
 *  @warning In order for animation delegates and callbacks to be executed,
 *           the main run loop is advanced multiples times. This makes it
 *           slow -- so avoid using this method if its not needed.
 *
 *  @seealso +[RBTimeLapse advanceMainRunLoop]
 */
+ (void)disableAnimationsInBlock:(void(^)())block;

/*! Advances the run loop. Unlike a simple -[NSRunLoop runUntilDate:],
 *  this will run until:
 *
 *   - all performSelector: calls are resolved.
 *   - the run loop is "waiting"
 *
 *  Also, all timers will change to have a 0 delay.
 *
 *  This may advance the run loop multiple times which can be problematic
 *  if you're attaching CFRunLoopObserverRefs to it.
 */
+ (void)advanceRunLoop:(NSRunLoop *)runLoop;

/*! Advances the main run loop.
 *
 *  Alias to +[RBTimeLapse advanceRunLoop:[NSRunLoop mainRunLoop]].
 */
+ (void)advanceMainRunLoop;


+ (void)resetMainRunLoop;
+ (void)resetRunLoop:(NSRunLoop *)nsRunLoop;

@end
