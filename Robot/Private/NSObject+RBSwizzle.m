#import "NSObject+RBSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (RBSwizzle)

+ (void)RB_swizzleInstanceMethod:(SEL)selector movingOldTo:(SEL)oldSelector replacingWith:(SEL)newSelector
{
    NSAssert([self instancesRespondToSelector:selector],
             @"%@ instances do not respond to %@; cannot swizzle",
             NSStringFromClass(self), NSStringFromSelector(selector));

    Method originalMethod = class_getInstanceMethod(self, selector);
    Method replacementMethod = class_getInstanceMethod(self, newSelector);
    const char *originalTypes = method_getTypeEncoding(originalMethod);
    NSAssert(strcmp(originalTypes, method_getTypeEncoding(replacementMethod)) == 0,
             @"Replacement and original class method do not have the same types: %s != %s for method %@",
             originalTypes, method_getTypeEncoding(replacementMethod),
             NSStringFromSelector(selector));

    class_addMethod(self, oldSelector, method_getImplementation(originalMethod), originalTypes);
    class_replaceMethod(self, selector, method_getImplementation(replacementMethod), originalTypes);
}

+ (void)RB_replaceInstanceMethod:(SEL)selector withMethod:(SEL)replacementSelector
{
    Method replacementMethod = class_getInstanceMethod(self, replacementSelector);
    const char *types = method_getTypeEncoding(replacementMethod);
    class_replaceMethod(self, selector, method_getImplementation(replacementMethod), types);
}

+ (void)RB_swizzleClassMethod:(SEL)selector movingOldTo:(SEL)oldSelector replacingWith:(SEL)newSelector
{
    Method originalMethod = class_getClassMethod(self, selector);
    Method replacementMethod = class_getClassMethod(self, newSelector);
    const char *originalTypes = method_getTypeEncoding(originalMethod);
    NSAssert(strcmp(originalTypes, method_getTypeEncoding(replacementMethod)) == 0,
             @"Replacement and original instance method do not have the same types: %s != %s for method %@",
             originalTypes, method_getTypeEncoding(replacementMethod),
             NSStringFromSelector(selector));

    Class superClass = class_getSuperclass(self);
    class_addMethod(superClass, oldSelector, method_getImplementation(originalMethod), originalTypes);
    class_replaceMethod(superClass, selector, method_getImplementation(replacementMethod), originalTypes);
}

+ (void)RB_replaceClassMethod:(SEL)selector withMethod:(SEL)replacementSelector
{
    Method replacementMethod = class_getClassMethod(self, replacementSelector);
    const char *types = method_getTypeEncoding(replacementMethod);
    Class superClass = class_getSuperclass(self);
    class_replaceMethod(superClass, selector, method_getImplementation(replacementMethod), types);
}

@end
