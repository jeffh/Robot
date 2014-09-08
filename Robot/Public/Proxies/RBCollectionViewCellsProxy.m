#import "RBCollectionViewCellsProxy.h"
#import "RBCellProxy.h"


@interface RBCollectionViewCellsProxy ()
@property (nonatomic) UICollectionView *collectionView;
@end


@implementation RBCollectionViewCellsProxy

+ (instancetype)cellsFromCollectionView:(UICollectionView *)collectionView
{
    return [[self alloc] initWithCollectionView:collectionView];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        self.collectionView = collectionView;
    }
    return self;
}

#pragma mark - Public

- (id)cellForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    return [self cellForIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
}

- (id)cellForIndexPath:(NSIndexPath *)indexPath
{
    return [[RBCellProxy alloc] initWithGetterBlock:^id{
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:self.preferredScrollPosition
                                            animated:NO];
        [self.collectionView layoutIfNeeded];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        return cell;
    }];
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
    NSUInteger totalSections = [self.collectionView numberOfSections];
    for (NSUInteger index = 0; index < totalSections; index++) {
        rowCount += [self.collectionView numberOfItemsInSection:index];
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
    for (NSUInteger index = 0, count = [self count]; index < count; index++) {
        [values addObject:[self[index] valueForKeyPath:keyPath]];
    }
    return values;
}

- (NSArray *)indexPaths
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSUInteger totalSections = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < totalSections; section++) {
        NSUInteger totalRows = [self.collectionView numberOfItemsInSection:section];
        for (NSUInteger row = 0; row < totalRows; row++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
        }
    }
    return indexPaths;
}

#pragma mark - Private

- (NSIndexPath *)indexPathForVisibleCellIndex:(NSUInteger)index
{
    NSUInteger rowCount = 0;
    NSUInteger totalSections = [self.collectionView numberOfSections];
    for (NSUInteger section = 0; section < totalSections; section++) {
        NSUInteger totalRows = [self.collectionView numberOfItemsInSection:section];
        if (index < rowCount + totalRows) {
            return [NSIndexPath indexPathForRow:index - rowCount inSection:section];
        }
        rowCount += totalRows;
    }
    return nil;
}

@end
