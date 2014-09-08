#import "SampleViewController.h"
#import "SampleCollectionViewCell.h"

@interface SampleViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource>
@property (nonatomic) NSUInteger numberOfTableViewSections;
@property (nonatomic) NSUInteger numberOfTableViewRows;
@property (nonatomic) NSUInteger numberOfCollectionViewSections;
@property (nonatomic) NSUInteger numberOfCollectionViewRows;
@end

@implementation SampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[SampleCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)fillTableViewWithNumberOfRows:(NSUInteger)rows andSections:(NSUInteger)sections
{
    self.numberOfTableViewSections = sections;
    self.numberOfTableViewRows = rows;
}

- (void)fillCollectionViewWithNumberOfRows:(NSUInteger)rows andSections:(NSUInteger)sections
{
    self.numberOfCollectionViewSections = sections;
    self.numberOfCollectionViewRows = rows;
}

#pragma mark - IBActions

- (IBAction)didTapButton:(id)sender
{
    self.buttonTapCount += 1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfTableViewSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfTableViewRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"Section %ld; Row %ld", (long)indexPath.section, (long)indexPath.row];
    cell.tag = indexPath.section * self.numberOfTableViewRows + indexPath.row;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.numberOfCollectionViewSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfCollectionViewRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SampleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Section %ld; Row %ld", (long)indexPath.section, (long)indexPath.row];
    cell.tag = indexPath.section * self.numberOfCollectionViewRows + indexPath.row;
    return cell;
}


@end
