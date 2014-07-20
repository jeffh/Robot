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
 */
@interface RBTableViewCellsProxy : NSArray

@property (nonatomic) UITableViewScrollPosition preferredScrollPosition;

+ (instancetype)cellsFromTableView:(UITableView *)tableView;

/*! Returns an array of all the indexPaths this table view has.
 */
- (NSArray *)indexPaths;

/*! Scrolls to a given index offset.
 */
- (void)scrollToIndex:(NSUInteger)index;

@end
