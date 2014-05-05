#import "RBAnimation.h"
#import <objc/runtime.h>

@interface UIView (RBAnimation)
+ (void)RB_attach;
+ (void)RB_detach;
@end

@interface UIView (RBAnimation_Swizzle)
+ (BOOL)RB_originalAreAnimationsEnabled;
@end

@implementation UIView (RBAnimation)

+ (void)RB_attach
{
    Method m = class_getClassMethod(self, @selector(areAnimationsEnabled));
    Method m2 = class_getClassMethod(self, @selector(RB_areAnimationsEnabled));
    Class metaClass = object_getClass(self);
    const char *typeEncoding = method_getTypeEncoding(m);
    if (![self respondsToSelector:@selector(RB_originalAreAnimationsEnabled)]) {
        class_addMethod(metaClass, @selector(RB_originalAreAnimationsEnabled), method_getImplementation(m), typeEncoding);
    }
    class_replaceMethod(metaClass, @selector(areAnimationsEnabled), method_getImplementation(m2), typeEncoding);
}

+ (void)RB_detach
{
    Method m = class_getClassMethod(self, @selector(areAnimationsEnabled));
    Class metaClass = object_getClass(self);
    const char *typeEncoding = method_getTypeEncoding(m);
    class_replaceMethod(metaClass, @selector(areAnimationsEnabled), method_getImplementation(m), typeEncoding);
}

+ (BOOL)RB_areAnimationsEnabled;
{
    return NO;
}

@end

@implementation RBAnimation

+ (void)disableAnimations
{
    [UIView setAnimationsEnabled:NO];
    [UIView RB_attach];
}

+ (void)enableAnimations
{
    [UIView setAnimationsEnabled:YES];
    [UIView RB_detach];
}

@end
