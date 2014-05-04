#import "UIView+RBTouch.h"
#import "RBTouch.h"


@implementation UIView (RBTouch)

- (void)tap
{
    [self tapAtPoint:self.center];
}

- (void)tapAtPoint:(CGPoint)point
{
    [RBTouch tapAtPoint:point inView:self.superview];
}

@end
