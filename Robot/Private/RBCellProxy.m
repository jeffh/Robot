#import "RBCellProxy.h"

@implementation RBCellProxy {
    id (^__getCell)();
}

- (id)initWithGetterBlock:(id(^)())getCellBlock;
{
    if (self) {
        __getCell = [getCellBlock copy];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return [self RB__retrieveCell];
}

- (id)valueForKey:(NSString *)key
{
    return [[self RB__retrieveCell] valueForKey:key];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    return [[self RB__retrieveCell] valueForKeyPath:keyPath];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    return [[self RB__retrieveCell] setValue:value forKey:key];
}

- (void)RB__makeVisible
{
    [self RB__retrieveCell];
}

#pragma mark - Private

- (id)RB__retrieveCell
{
    return __getCell();
}

@end
