#import <UIKit/UIKit.h>


/*! An NSArray-like interface to UITableView cells.
 *
 *  Like -[UITableView visibleCells], this will layout the table as needed.
 *  But unlike visibleCells, cells accessed off-screen are automatically
 *  scrolled to before accessing a cell property.
 *
 *  You can access cells like visibleCells:
 *
 *      RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:tableView];
 *      cells[0] // first cell
 *      cells[1] // second cell
 *      cells[2] // third cell
 *
 *  The returned cells are proxies to the underlying ones, so don't be too clever.
 */
@interface RBTableViewCellsProxy : NSArray

@property (nonatomic) UITableViewScrollPosition preferredScrollPosition;

+ (instancetype)cellsFromTableView:(UITableView *)tableView;

- (instancetype)init __attribute__((unavailable("Must use -initWithTableView:")));
- (instancetype)initWithTableView:(UITableView *)tableView;

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
