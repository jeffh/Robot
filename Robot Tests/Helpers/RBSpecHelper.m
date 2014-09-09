#import "RBSpecHelper.h"
#import "Robot.h"
#import "RBAssertionRecorder.h"

@implementation RBSpecHelper

+ (void)beforeEach
{
    [RBTimeLapse resetMainRunLoop];
}


+ (BOOL)raisesAssertionInBlock:(void(^)())block
{
    NSMutableDictionary *threadLocals = [[NSThread currentThread] threadDictionary];
    NSAssertionHandler *defaultHandler = [threadLocals objectForKey:NSAssertionHandlerKey];
    RBAssertionRecorder *recorder = [[RBAssertionRecorder alloc] init];
    threadLocals[NSAssertionHandlerKey] = recorder;
    @try {
        block();
        return recorder.assertionCount > 0;
    }
    @finally {
        if (defaultHandler) {
            threadLocals[NSAssertionHandlerKey] = defaultHandler;
        } else {
            [threadLocals removeObjectForKey:NSAssertionHandlerKey];
        }
    }
    return NO;
}

@end
