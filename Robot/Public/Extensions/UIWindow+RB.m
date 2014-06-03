#import "UIWindow+RB.h"

@implementation UIWindow (RB)

+ (instancetype)windowForTesting
{
    UIWindow *window = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [window makeKeyAndVisible];
    return window;
}

@end
