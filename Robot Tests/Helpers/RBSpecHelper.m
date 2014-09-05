#import "RBSpecHelper.h"
#import "Robot.h"

@implementation RBSpecHelper

+ (void)beforeEach
{
    [RBTimeLapse resetMainRunLoop];
}

@end
