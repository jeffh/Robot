#import "NotificationRecorder.h"

@implementation NotificationRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.notifications = [NSMutableArray array];
        self.notificationCenter = [NSNotificationCenter defaultCenter];
    }
    return self;
}

- (NSArray *)notificationNames
{
    return [self.notifications valueForKey:@"name"];
}

- (void)recordNotification:(NSNotification *)notification
{
    [self.notifications addObject:notification];
}

- (void)observeNotificationName:(NSString *)name
{
    [self.notificationCenter addObserver:self selector:@selector(recordNotification:) name:name object:nil];
}

- (void)stopObservingNotificationName:(NSString *)name
{
    [self.notificationCenter removeObserver:self name:name object:nil];
}

- (void)dealloc
{
    [self.notificationCenter removeObserver:self];
}

@end
