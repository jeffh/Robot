#import <UIKit/UIKit.h>

@interface SampleViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSUInteger buttonTapCount;

- (void)fillTableViewWithNumberOfRows:(NSUInteger)rows andSections:(NSUInteger)sections;
- (void)fillCollectionViewWithNumberOfRows:(NSUInteger)rows andSections:(NSUInteger)sections;

@end
