#import <UIKit/UIKit.h>

@interface RBTableViewCellProxy : NSProxy

- (id)initWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath preferredScrollPosition:(UITableViewScrollPosition)scrollPosition;

- (void)RB__makeVisible;

@end
