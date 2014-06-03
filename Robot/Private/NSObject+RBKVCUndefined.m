#import "NSObject+RBKVCUndefined.h"
#import "NSObject+RBSwizzle.h"

@interface NSObject (RBKVCUndefined_original)

- (id)RB_originalValueForUndefinedKey:(NSString *)key;

@end

@implementation NSObject (RBKVCUndefined)

static NSMutableDictionary *RBSwizzledClasses;

- (id)RB_valueForUndefinedKey:(NSString *)key
{
    return nil;
}

+ (void)RB_allowUndefinedKeys:(BOOL)allowUndefinedKeys {
    @synchronized (RBSwizzledClasses) {
        if (!RBSwizzledClasses) {
            RBSwizzledClasses = [[NSMutableDictionary alloc] init];
        }
        NSString *key = NSStringFromClass(self);
        if (allowUndefinedKeys == [RBSwizzledClasses[key] boolValue]) {
            return;
        }

        if (allowUndefinedKeys) {
            [self RB_swizzleInstanceMethod:@selector(valueForUndefinedKey:)
                               movingOldTo:@selector(RB_originalValueForUndefinedKey:)
                             replacingWith:@selector(RB_valueForUndefinedKey:)];
        } else {
            [self RB_replaceInstanceMethod:@selector(valueForUndefinedKey:)
                                withMethod:@selector(RB_originalValueForUndefinedKey:)];
        }
        RBSwizzledClasses[key] = @(allowUndefinedKeys);
    }
}

@end
