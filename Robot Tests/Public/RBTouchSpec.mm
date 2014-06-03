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
