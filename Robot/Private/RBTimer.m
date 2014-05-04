#import "RBTimer.h"


@interface RBTimer ()

@property (nonatomic) NSRunLoop *runLoop;
@property (nonatomic) NSTimeInterval pollInterval;

@end


@implementation RBTimer

+ (instancetype)defaultTimer
{
    static RBTimer *RBTimer__;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RBTimer__ = [[self alloc] initWithRunLoop:[NSRunLoop mainRunLoop] pollingInterval:0];
    });
    return RBTimer__;
}

- (instancetype)initWithRunLoop:(NSRunLoop *)runLoop pollingInterval:(NSTimeInterval)pollInterval
{
    self = [super init];
    self.runLoop = runLoop;
    self.pollInterval = pollInterval;
    return self;
}

- (BOOL)waitForAtMostTime:(NSTimeInterval)maxTimeInterval block:(RBWatchBlock)block
{
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:maxTimeInterval];
    do {
        if (block()) {
            return YES;
        }
        [self.runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.pollInterval]];
    } while ([[NSDate date] laterDate:endDate] == endDate);

    return NO;
}

- (void)waitOrFailForName:(NSString *)name forAtMostTime:(NSTimeInterval)maxTimeInterval block:(RBWatchBlock)block
{
    BOOL result = [self waitForAtMostTime:maxTimeInterval block:block];
    if (!result) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed: gave up waiting for %@ (waited %.2f seconds)", name, maxTimeInterval];
    }
}

- (void)waitForTime:(NSTimeInterval)time
{
    [self.runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:time]];
}

@end
