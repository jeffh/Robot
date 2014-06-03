#import "SampleViewController.h"

@interface SampleViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSUInteger numberOfSections;
@property (nonatomic) NSUInteger numberOfRows;
@end

@implementation SampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)fillTableViewWithNumberOfRows:(NSUInteger)rows andSections:(NSUInteger)sections
{
    self.numberOfSections = sections;
    self.numberOfRows = rows;
}

#pragma mark - IBActions

- (IBAction)didTapButton:(id)sender
{
    self.buttonTapCount += 1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Section %ld; Row %ld", (long)indexPath.section, (long)indexPath.row];
    cell.tag = indexPath.section * self.numberOfRows + indexPath.row;
    return cell;
}

@end
