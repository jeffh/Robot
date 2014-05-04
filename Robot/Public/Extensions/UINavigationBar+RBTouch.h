#import <UIKit/UIKit.h>


@interface UINavigationBar (RBTouch)

/*! Tap on the left bar button at index zero.
 *
 *  Alias to -[tapLeftBarButtonAtIndex:0]
 */
- (void)tapLeftBarButton;

/*! Tap on the right bar button at index zero.
 *
 *  Alias to -[tapRightBarButtonAtIndex:0]
 */
- (void)tapRightBarButton;

/*! Tap on the left bar button for a given index
 */
- (void)tapLeftBarButtonAtIndex:(NSInteger)index;

/*! Tap on the right bar button for a given index
 */
- (void)tapRightBarButtonAtIndex:(NSInteger )index;

@end
