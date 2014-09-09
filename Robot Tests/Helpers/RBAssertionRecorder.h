#import <Foundation/Foundation.h>

@interface RBAssertionRecorder : NSAssertionHandler

@property (nonatomic) NSUInteger assertionCount;

@end
