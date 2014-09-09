#import "RBAssertionRecorder.h"

@implementation RBAssertionRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assertionCount = 0;
    }
    return self;
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,... NS_FORMAT_FUNCTION(5,6)
{
    self.assertionCount++;
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format,... NS_FORMAT_FUNCTION(4,5)
{
    self.assertionCount++;
}

@end
