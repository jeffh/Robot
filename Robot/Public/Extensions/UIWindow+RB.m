#import "UIWindow+RB.h"

@implementation UIWindow (RB)

+ (instancetype)createWindowForTesting
{
    UIWindow *window = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [window makeKeyAndVisible];
    return window;
}

@end
