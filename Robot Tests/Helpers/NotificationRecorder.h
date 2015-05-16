#import <Foundation/Foundation.h>

@interface NotificationRecorder : NSObject

@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;

- (NSArray *)notificationNames;

- (void)recordNotification:(NSNotification *)notification;
- (void)observeNotificationName:(NSString *)name;
- (void)stopObservingNotificationName:(NSString *)name;

@end
