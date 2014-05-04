#import <UIKit/UIKit.h>


/*! Handles retrieving views from accessibility.
 */
@interface RBAccessibility : NSObject

- (instancetype)initWithWindow:(UIWindow *)window raiseExceptionsIfCannotFindObjects:(BOOL)shouldRaiseExceptions;
- (UINavigationController *)rootNavigationController;
- (UINavigationBar *)rootNavigationBar;
- (id)viewWithIdentifier:(NSString *)accessibilityIdentifier;
- (id)viewWithLabel:(NSString *)accessibilityLabel;

@end
