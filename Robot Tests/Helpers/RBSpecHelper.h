#import <Foundation/Foundation.h>

@interface RBSpecHelper : NSObject

+ (BOOL)raisesAssertionInBlock:(void(^)())block;

@end
