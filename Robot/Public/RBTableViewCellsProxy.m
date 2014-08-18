#import "RBTableViewCellsProxy.h"
#import "RBTableViewCellProxy.h"


@interface RBTableViewCellsProxy ()

@property (nonatomic) UITableView *tableView;

@end


@implementation RBTableViewCellsProxy

+ (instancetype)cellsFromTableView:(UITableView *)tableView
{
    return [[self alloc] initWithTableView:tableView];
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.preferredScrollPosition = UITableViewScrollPositionMiddle;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Public

- (id)cellForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    return [self cellForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (id)cellForIndexPath:(NSIndexPath *)indexPath
{
    return [[RBTableViewCellProxy alloc] initWithTableView:self.tableView
                                                 indexPath:indexPath
                                   preferredScrollPosition:self.preferredScrollPosition];
}

- (id)cellAtIndex:(NSUInteger)index
{
    return self[index];
}

- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section
{
    [self scrollToIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath
{
    [[self cellForIndexPath:indexPath] RB__makeVisible];
}

- (void)scrollToIndex:(NSUInteger)index
{
    [self[index] RB__makeVisible];
}

#pragma mark - NSArray

- (NSUInteger)count
{
    NSUInteger rowCount = 0;
    NSUInteger totalSections = [self.tableView numberOfSections];
    for (NSUInteger i = 0; i < totalSections; i++) {
        rowCount += [self.tableView numberOfRowsInSection:i];
    }
    return rowCount;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self cellForIndexPath:[self indexPathForVisibleCellIndex:index]];
}

#pragma mark - NSObject

- (id)valueForKeyPath:(NSString *)keyPath
{
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger i = 0, c = [self count]; i < c; i++) {
        [values addObject:[self[i] valueForKeyPath:keyPath]];
    }
    return values;
}

- (NSArray *)indexPaths
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger totalSections = [self.tableView numberOfSections];
    for (NSUInteger i = 0; i < totalSections; i++) {
        NSUInteger totalRows = [self.tableView numberOfRowsInSection:i];
        for (NSUInteger j = 0; j < totalRows; j++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
        }
    }
    return indexPaths;
}

#pragma mark - Private

- (NSIndexPath *)indexPathForVisibleCellIndex:(NSUInteger)index
{
    NSUInteger rowCount = 0;
    NSUInteger totalSections = [self.tableView numberOfSections];
    for (NSUInteger i = 0; i < totalSections; i++) {
        NSUInteger totalRows = [self.tableView numberOfRowsInSection:i];
        if (index < rowCount + totalRows) {
            return [NSIndexPath indexPathForRow:index - rowCount inSection:i];
        }
        rowCount += totalRows;
    }
    return nil;
}

@end
