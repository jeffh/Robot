#import "UINavigationBar+RBTouch.h"
#import "RBDSL.h"


@interface UINavigationBar (PrivateAPIs)

- (NSArray *)_currentLeftViews;
- (NSArray *)_currentRightViews;

@end


@implementation UINavigationBar (RBTouch)

- (void)tapLeftBarButton
{
    return [self tapLeftBarButtonAtIndex:0];
}

- (void)tapRightBarButton
{
    return [self tapRightBarButtonAtIndex:0];
}

- (void)tapLeftBarButtonAtIndex:(NSInteger)index
{
    UIView *subview = [self _currentLeftViews][index];
    tapOn(subview);
}

- (void)tapRightBarButtonAtIndex:(NSInteger)index
{
    UIView *subview = [self _currentRightViews][index];
    tapOn(subview);
}

@end
