#import <UIKit/UIKit.h>

/*! Manages view retrieval and layout.
 */
@interface RBAccessibility : NSObject

/*! Returns a shared instance. This class maintains no state, so this is simply
 *  an alternative to creating an RBAccessibility object each time.
 */
+ (instancetype)sharedInstance;

/*! Returns all subviews that match the given predicate. This will recursively
 *  walk through all subviews in the view hierarchy.
 */
- (NSArray *)subviewsInView:(UIView *)view
        satisfyingPredicate:(NSPredicate *)predicate;

/*! Returns all subviews that match the given predicate. This will recursively
 *  walk through all subviews in the view hierarchy for each view in the provided
 *  array of views.
 */
- (NSArray *)subviewsOfViews:(NSArray *)views
         satisfyingPredicate:(NSPredicate *)predicate;

/*! Recursively lays out all windows in the application
 */
- (void)layoutApplication;

/*! Returns all windows. Identical to [[UIApplication sharedApplication] windows] except
 *  it may include a private UIWindow when alerts are visible.
 *
 *  Uses private APIs.
 */
- (NSArray *)windows;

/*! Returns the key window. Identical to [[UIApplication sharedApplication] keyWindow] except
 *  it may be a private UIWindow (eg - the alert window) when presently taking input
 *  from the user.
 *
 *  Uses private APIs.
 */
- (UIWindow *)keyWindow;

/*! Returns YES if the is currently an alert view or controller visible.
 *
 *  Uses private APIs.
 */
- (BOOL)isAlertShowing;

/*! Removes all UIAlertViews and UIAlertControllers that are visible.
 *  This should be executed before each test.
 *
 *  Uses private APIs.
 */
- (void)removeAllAlerts;

@end
