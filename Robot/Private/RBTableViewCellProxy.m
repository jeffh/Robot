#import "RBTableViewCellProxy.h"

@implementation RBTableViewCellProxy {
    UITableView *__tableView;
    NSIndexPath *__indexPath;
    UITableViewScrollPosition __scrollPosition;
}

- (id)initWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath preferredScrollPosition:(UITableViewScrollPosition)scrollPosition
{
    if (self) {
        __tableView = tableView;
        __indexPath = indexPath;
        __scrollPosition = scrollPosition;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return [self __retrieveCell];
}

- (id)valueForKey:(NSString *)key
{
    return [[self __retrieveCell] valueForKey:key];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    return [[self __retrieveCell] valueForKeyPath:keyPath];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    return [[self __retrieveCell] setValue:value forKey:key];
}

- (void)__makeVisible
{
    [self __retrieveCell];
}

#pragma mark - Private

- (UITableViewCell *)__retrieveCell
{
    [__tableView scrollToRowAtIndexPath:__indexPath
                       atScrollPosition:__scrollPosition
                               animated:NO];
    [__tableView layoutIfNeeded];
    return [__tableView cellForRowAtIndexPath:__indexPath];
}

@end
