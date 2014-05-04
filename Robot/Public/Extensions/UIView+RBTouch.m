#import "UIView+RBTouch.h"
#import "RBFinger.h"


@implementation UIView (RBTouch)

- (void)tap
{
    [self tapAtPoint:self.center];
}

- (void)tapAtPoint:(CGPoint)point
{
    [RBFinger tapPoint:point inView:self];
}

@end
