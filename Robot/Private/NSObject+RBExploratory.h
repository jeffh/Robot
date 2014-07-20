#import <Foundation/Foundation.h>

@interface NSObject (RBExploratory)

- (id)RB_objectFromInstanceVariableName:(NSString *)ivarName;
- (void)RB_setObject:(id)object forInstanceVariableName:(NSString *)ivarName;

@end
