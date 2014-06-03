#import "Robot.h"
#import "SampleViewController.h"
#import "RBAnimation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBAccessibilitySpec)

describe(@"RBAccessibility", ^{
    __block RBAccessibility *accessibility;
    __block SampleViewController *controller;

    beforeEach(^{
        controller = [[SampleViewController alloc] init];
        accessibility = [[RBAccessibility alloc] init];
        controller.view should_not be_nil;
    });

    it(@"should not display any alert views", ^{
        [accessibility isAlertViewShowing] should be_falsy;
    });

    describe(@"alert views", ^{
        __block UIAlertView *firstAlert, *secondAlert;
        __block NSObject<UIAlertViewDelegate, CedarDouble> *alertDelegate;

        beforeEach(^{
            alertDelegate = nice_fake_for(@protocol(UIAlertViewDelegate));
            firstAlert = [[UIAlertView alloc] initWithTitle:@"First" message:@"message" delegate:alertDelegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            secondAlert = [[UIAlertView alloc] initWithTitle:@"Second" message:@"message" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

            [RBAnimation disableAnimationsInBlock:^{
                [firstAlert show];
            }];
        });

        it(@"should find the alert view", ^{
            [accessibility isAlertViewShowing] should be_truthy;
        });

        context(@"dismissing the alert view", ^{
            beforeEach(^{
                tapOn(theFirstView(withLabel(@"Cancel")));
            });

            it(@"should call the delegate", ^{
                alertDelegate should have_received(@selector(willPresentAlertView:)).with(firstAlert);
                alertDelegate should have_received(@selector(alertViewShouldEnableFirstOtherButton:)).with(firstAlert);
                alertDelegate should have_received(@selector(alertView:clickedButtonAtIndex:)).with(firstAlert, 0);
                alertDelegate should have_received(@selector(didPresentAlertView:)).with(firstAlert);
                alertDelegate should have_received(@selector(alertView:willDismissWithButtonIndex:)).with(firstAlert, 0);
                alertDelegate should have_received(@selector(alertView:didDismissWithButtonIndex:)).with(firstAlert, 0);
            });

            it(@"should return nil", ^{
                [accessibility isAlertViewShowing] should be_truthy;
            });
        });

        context(@"displaying another alert view", ^{
            beforeEach(^{
                [secondAlert show];
            });

            it(@"should find the most recently shown alert view", ^{
                [accessibility isAlertViewShowing] should be_truthy;
            });

            context(@"after dismissing the alert view", ^{
                beforeEach(^{
                    tapOn(theFirstView(withLabel(@"Cancel")));
                });

                it(@"should show the previous alert view", ^{
                    [accessibility isAlertViewShowing] should be_truthy;
                });
            });

            context(@"after dismissing all the alert views", ^{
                beforeEach(^{
                    tapOn(theFirstView(withLabel(@"Cancel")));
                    tapOn(theFirstView(withLabel(@"Cancel")));
                });

                it(@"should return nil", ^{
                    [accessibility isAlertViewShowing] should be_truthy;
                });
            });
        });
    });

    describe(@"finding views", ^{
        it(@"should be able to find views by class", ^{
            allViews(ofExactClass([UILabel class]), controller.view) should equal(@[controller.label]);
        });

        it(@"should be able to find views by accessibility label", ^{
            allViews(withLabel(@"label1"), controller.view) should equal(@[controller.label, controller.textField]);
            theFirstView(withLabel(@"label1"), controller.view) should equal(controller.label);
        });

        it(@"should be able to find views by predicate", ^{
            allViews(where(@"self == %@", controller.textField));
        });
    });
});

SPEC_END
