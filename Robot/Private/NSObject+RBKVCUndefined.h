#import <Foundation/Foundation.h>

@interface NSObject (RBKVCUndefined)

+ (void)RB_allowUndefinedKeys:(BOOL)allowUndefinedKeys;
+ (void)RB_allowUndefinedKeysInBlock:(void(^)())block;

@end
