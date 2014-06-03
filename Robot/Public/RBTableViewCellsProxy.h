#import <UIKit/UIKit.h>

@interface RBTableViewCellsProxy : NSArray

@property (nonatomic) UITableViewScrollPosition preferredScrollPosition;

+ (instancetype)cellsFromTableView:(UITableView *)tableView;

- (NSArray *)indexPaths;
- (void)scrollToIndex:(NSUInteger)index;

@end
