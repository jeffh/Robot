#import <UIKit/UIKit.h>


@interface RBDriver : NSObject

/*! Setting this property to YES will cause the keyboard entry to be slower, but emulates more
 *  of what a user does.
 *
 *  The default is NO.
 */
@property (nonatomic, getter = areKeyboardAnimationsEnabled) BOOL keyboardAnimationsEnabled;
/*! The current view controller under test. Setting this property simply sets the
 *  window's rootViewController property.
 */
@property (nonatomic) UIViewController *viewController;

/*! Returns the window that this driver operates on.
 */
@property (nonatomic, readonly) UIWindow *window;

/*! Returns the boolean indicating if UIView animations are enabled or disabled.
 */
@property (nonatomic, readonly, getter = areAnimationsDisabled) BOOL animationsDisabled;

/*! Creates a new driver that sets up Robot.
 *
 *  @param window The window to operate on. This can either be a new one or an existing one.
 *  @param disableAnimations Whether or not UIView animations should be disabled or enabled.
 *  @param pollingInterval How often this driver should "sleep" between asynchronous operations.
 *  @param raiseExceptionsIfNotFound When using methods that seach, this driver should raise
 *                                   exceptions instead of returning nil.
 */
- (instancetype)initWithWindow:(UIWindow *)window
             disableAnimations:(BOOL)disableAnimations
               pollingInterval:(NSTimeInterval)pollInterval
     raiseExceptionsIfNotFound:(BOOL)raiseExceptionsIfNotFound;

/*! Prepares the driver to test view controllers its given.
 */
- (void)setup;

/*! Restores the state the driver prior to -[setup].
 */
- (void)teardown;

#pragma mark - Output

/*! Returns the first view in the window hierarchy that has the given accessibility label.
 */
- (id)viewWithAccessibilityLabel:(NSString *)label;
/*! Returns the first view in the window hierarchy that has the given accessibility identifier.
 */
- (id)viewWithAccessibilityIdentifier:(NSString *)identifier;

/*! Finds the first navigation controller in the controller hierarchy.
 */
- (UINavigationController *)rootNavigationController;
/*! Finds the first navigation bar in the controller hierarchy.
 */
- (UINavigationBar *)rootNavigationBar;

#pragma mark - Input

/*! Types the given string through the system keyboard.
 */
- (void)typeString:(NSString *)string;

/*! Types the given key through the system keyboard.
 *  This is useful for special keys that cannot be represented as
 *  a single character.
 *
 *  See RBConstants for some examples (eg - RBKeyMore).
 */
- (void)typeKey:(NSString *)key;

/*! Types the array of keys through the system keyboard.
 */
- (void)typeKeys:(NSArray *)keys;

@end
