#import "RBTableViewCellsProxy.h"
#import "SampleViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBTableViewCellsProxySpec)

describe(@"RBTableViewCellsProxy", ^{
    __block RBTableViewCellsProxy *subject;
    __block SampleViewController *controller;

    beforeEach(^{
        controller = [[SampleViewController alloc] init];
        [controller fillTableViewWithNumberOfRows:5 andSections:2];
        controller.view should_not be_nil;

        subject = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
    });

    it(@"should return all the index paths", ^{
        subject.indexPaths should equal(@[[NSIndexPath indexPathForRow:0 inSection:0],
                                          [NSIndexPath indexPathForRow:1 inSection:0],
                                          [NSIndexPath indexPathForRow:2 inSection:0],
                                          [NSIndexPath indexPathForRow:3 inSection:0],
                                          [NSIndexPath indexPathForRow:4 inSection:0],
                                          [NSIndexPath indexPathForRow:0 inSection:1],
                                          [NSIndexPath indexPathForRow:1 inSection:1],
                                          [NSIndexPath indexPathForRow:2 inSection:1],
                                          [NSIndexPath indexPathForRow:3 inSection:1],
                                          [NSIndexPath indexPathForRow:4 inSection:1]]);
    });

    it(@"should return the number of cells", ^{
        subject.count should equal(10);
    });

    it(@"should allow fetching of all the cells", ^{
        [subject[0] textLabel].text should equal(@"Section 0; Row 0");
        [subject[1] textLabel].text should equal(@"Section 0; Row 1");
        [subject[2] textLabel].text should equal(@"Section 0; Row 2");
        [subject[3] textLabel].text should equal(@"Section 0; Row 3");
        [subject[4] textLabel].text should equal(@"Section 0; Row 4");
        [subject[5] textLabel].text should equal(@"Section 1; Row 0");
        [subject[6] textLabel].text should equal(@"Section 1; Row 1");
        [subject[7] textLabel].text should equal(@"Section 1; Row 2");
        [subject[8] textLabel].text should equal(@"Section 1; Row 3");
        [subject[9] textLabel].text should equal(@"Section 1; Row 4");
    });

    it(@"should allow valueForKey: on all the cells", ^{
        [subject valueForKey:@"tag"] should equal(@[@0,
                                                    @1,
                                                    @2,
                                                    @3,
                                                    @4,
                                                    @5,
                                                    @6,
                                                    @7,
                                                    @8,
                                                    @9]);
    });

    it(@"should allow valueForKeyPath: on all the cells", ^{
        [subject valueForKeyPath:@"textLabel.text"] should equal(@[@"Section 0; Row 0",
                                                                   @"Section 0; Row 1",
                                                                   @"Section 0; Row 2",
                                                                   @"Section 0; Row 3",
                                                                   @"Section 0; Row 4",
                                                                   @"Section 1; Row 0",
                                                                   @"Section 1; Row 1",
                                                                   @"Section 1; Row 2",
                                                                   @"Section 1; Row 3",
                                                                   @"Section 1; Row 4"]);
    });
});

SPEC_END
