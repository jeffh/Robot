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

- (UITableViewCell *)RB__retrieveCell
{
    [__tableView scrollToRowAtIndexPath:__indexPath
                       atScrollPosition:__scrollPosition
                               animated:NO];
    [__tableView layoutIfNeeded];
    UITableViewCell *cell = [__tableView cellForRowAtIndexPath:__indexPath];
    [cell layoutIfNeeded];
    return cell;
}

@end
