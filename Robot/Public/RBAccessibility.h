#import <UIKit/UIKit.h>

@class RBTimer;

/*! Handles retrieving views from accessibility.
 */
@interface RBAccessibility : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init;
- (instancetype)initAndRaiseExceptionsIfCannotFindObjects:(BOOL)shouldRaiseExceptions;
- (UINavigationController *)findNavigationControllerInViewController:(UIViewController *)rootViewController;
- (UINavigationBar *)findNavigationBarInViewController:(UIViewController *)rootViewController;
- (NSArray *)subviewsInView:(UIView *)view withIdentifier:(NSString *)accessibilityIdentifier;
- (NSArray *)subviewsInView:(UIView *)view withLabel:(NSString *)accessibilityLabel;
- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicateFormat:(NSString *)format, ...;
- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicateFormat:(NSString *)format arguments:(va_list)arguments;
- (NSArray *)subviewsInView:(UIView *)view satisfyingPredicate:(NSPredicate *)predicate;
- (void)layoutView:(UIView *)view;
- (UIAlertView *)visibleAlertView;

@end
