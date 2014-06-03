#import <Foundation/Foundation.h>

@interface NSObject (RBExploratory)

- (id)objectFromInstanceVariableName:(NSString *)ivarName;
- (void)setObject:(id)object forInstanceVariableName:(NSString *)ivarName;

@end
