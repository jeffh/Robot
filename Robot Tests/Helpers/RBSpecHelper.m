#import "RBSpecHelper.h"

@implementation RBSpecHelper

+ (void)beforeEach
{
    static BOOL isFirstRun = YES;
    if (isFirstRun) {
        [NSThread sleepForTimeInterval:1];
        isFirstRun = NO;
    }
}

@end
