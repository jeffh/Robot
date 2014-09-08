#import <UIKit/UIKit.h>


@interface RBCollectionViewCellsProxy : NSArray

@property (nonatomic) UICollectionViewScrollPosition preferredScrollPosition;

+ (instancetype)cellsFromCollectionView:(UICollectionView *)collectionView;
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

/*! Returns a table view cell at the given index path
 */
- (id)cellForRow:(NSUInteger)row inSection:(NSUInteger)section;

/*! Returns a table view cell at the given index path
 */
- (id)cellForIndexPath:(NSIndexPath *)indexPath;

/*! Returns a table view cell at the given index
 */
- (id)cellAtIndex:(NSUInteger)index; // alias to index access

/*! Returns an array of all the indexPaths this table view has.
 */
- (NSArray *)indexPaths;

/*! Scrolls to a given cell at a given index path
 */
- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section;

/*! Scrolls to a given cell at a given index path
 */
- (void)scrollToIndexPath:(NSIndexPath *)indexPath;

/*! Scrolls to a given cell at a given index offset.
 */
- (void)scrollToIndex:(NSUInteger)index;

@end
