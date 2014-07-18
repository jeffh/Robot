#import <UIKit/UIKit.h>

/*! Handles retrieving views.	g
 */
@interface RBAccessibility : NSObject

/*!
 */
+ (instancetype)sharedInstance;

- (NSArray *)subviewsInView:(UIView *)view
        satisfyingPredicate:(NSPredicate *)predicate;

- (NSArray *)subviewsOfViews:(NSArray *)views satisfyingPredicate:(NSPredicate *)predicate;

- (NSArray *)windows;

- (void)layoutView:(UIView *)view;
- (BOOL)isAlertViewShowing;

/*! Removes all alert views presented. Should be executed before each test.
 *
 *  Note: if you're using Cedar, this is called for you automatically
 */
- (void)cleanup;

@end
