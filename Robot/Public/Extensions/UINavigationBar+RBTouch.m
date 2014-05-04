#import "UINavigationBar+RBTouch.h"
#import "UIView+RBTouch.h"


@interface UINavigationBar (PrivateAPIs)

- (NSArray *)_currentLeftViews;
- (NSArray *)_currentRightViews;

@end


@implementation UINavigationBar (RBTouch)

- (void)tapLeftBarButton
{
    return [self tapLeftBarButtonIndex:0];
}

- (void)tapRightBarButton
{
    return [self tapRightBarButtonIndex:0];
}

- (void)tapLeftBarButtonIndex:(NSInteger)index
{
    UIView *subview = [self _currentLeftViews][index];
    [subview tap];
}

- (void)tapRightBarButtonIndex:(NSInteger)index
{
    UIView *subview = [self _currentRightViews][index];
    [subview tap];
}

@end
