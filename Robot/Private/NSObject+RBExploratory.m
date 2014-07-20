#import "NSObject+RBExploratory.h"
#import <objc/runtime.h>

@implementation NSObject (RBExploratory)

- (id)RB_objectFromInstanceVariableName:(NSString *)ivarName
{
    return object_getIvar(self, class_getInstanceVariable([self class], ivarName.UTF8String));
}

- (void)RB_setObject:(id)object forInstanceVariableName:(NSString *)ivarName
{
    return object_setIvar(self, class_getInstanceVariable([self class], ivarName.UTF8String), object);
}

@end
