#import "Robot.h"
#import "SampleViewController.h"
#import "RBKeyboard.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBTouchSpec)

describe(@"RBTouch", ^{
    __block SampleViewController *controller;

    beforeEach(^{
        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
        [[UIWindow createWindowForTesting] addSubview:controller.view];
    });

    describe(@"triggering a tableview pan gesture recognizer", ^{
        __block NSMutableArray *target;

        beforeEach(^{
            target = [NSMutableArray array];
            [controller fillTableViewWithNumberOfRows:10 andSections:2];
            swipeLeftOn(theFirstView(ofClass([UITableViewCell class])).sortedBy(@[smallestOrigin()]));
        });

        it(@"should show the delete menu", ^{
            theFirstView(withText(@"Delete")) should_not be_nil;
        });
    });

    describe(@"triggering a pan gesture recognizer", ^{
        __block NSMutableArray *target;
        __block UIPanGestureRecognizer *panGestureRecognizer;

        beforeEach(^{
            controller.tableView.hidden = YES; // otherwise this will capture our swipes

            target = [NSMutableArray array];
            panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(addObject:)];
            [controller.view addGestureRecognizer:panGestureRecognizer];
            spy_on(panGestureRecognizer);
            swipeLeftOn(controller.view);
        });

        it(@"should trigger the gesture recognizer", ^{
            target should_not be_empty;
        });
    });

    describe(@"triggering a tap gesture recognizer", ^{
        __block NSMutableArray *target;
        __block UITapGestureRecognizer *tapGestureRecognizer;

        beforeEach(^{
            target = [NSMutableArray array];
            tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(addObject:)];
            [controller.view addGestureRecognizer:tapGestureRecognizer];
            tapOn(controller.view);
        });

        it(@"should trigger the gesture recognizer", ^{
            target should equal(@[tapGestureRecognizer]);
        });
    });

    describe(@"triggering a swipe gesture recognizer", ^{
        __block NSMutableArray *target;
        __block UISwipeGestureRecognizer *swipeGestureRecognizer;

        beforeEach(^{
            target = [NSMutableArray array];
            swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:@selector(addObject:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            controller.tableView.hidden = YES; // otherwise this will capture our swipes
            [controller.view addGestureRecognizer:swipeGestureRecognizer];
        });

        it(@"should trigger the gesture recognizer if it matches the same direction (left)", ^{
            swipeLeftOn(controller.view);
            target should equal(@[swipeGestureRecognizer]);
        });

        it(@"should trigger the gesture recognizer if it matches the same direction (right)", ^{
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            swipeRightOn(controller.view);
            target should equal(@[swipeGestureRecognizer]);
        });

        it(@"should trigger the gesture recognizer if it matches the same direction (up)", ^{
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
            swipeUpOn(controller.view);
            target should equal(@[swipeGestureRecognizer]);
        });

        it(@"should trigger the gesture recognizer if it matches the same direction (down)", ^{
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            swipeDownOn(controller.view);
            target should equal(@[swipeGestureRecognizer]);
        });

        it(@"should not trigger the gesture recognizer if it does not match the same direction", ^{
            swipeRightOn(controller.view);
            target should be_empty;
        });
    });

    describe(@"tapping on buttons", ^{
        beforeEach(^{
            tapOn(controller.button);
        });

        it(@"should fire its events appropriately", ^{
            controller.buttonTapCount should equal(1);
        });
    });
});

SPEC_END
