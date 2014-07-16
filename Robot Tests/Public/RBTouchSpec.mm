#import "Robot.h"
#import "SampleViewController.h"
#import "UIView+RBTouch.h"
#import "RBKeyboard.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBTouchSpec)

describe(@"RBTouch", ^{
    __block SampleViewController *controller;

    beforeEach(^{
        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
        [[UIWindow windowForTesting] addSubview:controller.view];
    });

    describe(@"triggering a tap gesture recognizer", ^{
        __block NSMutableArray *target;
        __block UITapGestureRecognizer *tapGestureRecognizer;

        beforeEach(^{
            target = [NSMutableArray array];
            tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(addObject:)];
            [controller.view addGestureRecognizer:tapGestureRecognizer];
            [controller.view tap];
        });

        it(@"should trigger the gesture recognizer", ^{
            target should equal(@[tapGestureRecognizer]);
        });
    });

    describe(@"a swipe gesture", ^{
        __block NSMutableArray *target;
        __block UISwipeGestureRecognizer *swipeGestureRecognizer;

        beforeEach(^{
            target = [NSMutableArray array];
            swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:target action:@selector(addObject:)];
            swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            controller.tableView.hidden = YES;
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
            [controller.button tap];
        });

        it(@"should fire its events appropriately", ^{
            controller.buttonTapCount should equal(1);
        });
    });
});

SPEC_END
