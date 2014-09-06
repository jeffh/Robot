#import "Robot.h"
#import "SampleViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBAccessibilitySpec)

describe(@"RBAccessibility", ^{
    __block SampleViewController *controller;

    beforeEach(^{
        removeAllAlerts();

        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
    });

    it(@"should not display any alert views", ^{
        isAlertVisible() should be_falsy;
    });

    it(@"should be able to compare subviews", ^{
        allViews(where(@"subviews[SIZE] > 2")) should_not be_empty;
    });

    describe(@"alert views", ^{
        __block UIAlertView *firstAlert, *secondAlert;
        __block NSObject<UIAlertViewDelegate, CedarDouble> *alertDelegate;

        beforeEach(^{
            alertDelegate = nice_fake_for(@protocol(UIAlertViewDelegate));
            firstAlert = [[UIAlertView alloc] initWithTitle:@"First"
                                                    message:@"message"
                                                   delegate:alertDelegate
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
            secondAlert = [[UIAlertView alloc] initWithTitle:@"Second"
                                                     message:@"message"
                                                    delegate:nil
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil];

            [RBTimeLapse disableAnimationsInBlock:^{
                [firstAlert show];
            }];
        });

        it(@"should find the alert view", ^{
            isAlertVisible() should be_truthy;
        });

        context(@"dismissing the alert view", ^{
            beforeEach(^{
                tapOn(theFirstView(withLabel(@"Cancel")));
            });

            it(@"should call the delegate", ^{
                alertDelegate should have_received(@selector(willPresentAlertView:)).with(firstAlert);
                alertDelegate should have_received(@selector(alertView:clickedButtonAtIndex:)).with(firstAlert, 0);
                alertDelegate should have_received(@selector(didPresentAlertView:)).with(firstAlert);
                alertDelegate should have_received(@selector(alertView:willDismissWithButtonIndex:)).with(firstAlert, 0);
                alertDelegate should have_received(@selector(alertView:didDismissWithButtonIndex:)).with(firstAlert, 0);
            });

            it(@"should hide the alert view", ^{
                isAlertVisible() should be_falsy;
            });
        });

        context(@"displaying another alert view", ^{
            beforeEach(^{
                [RBTimeLapse disableAnimationsInBlock:^{
                    [secondAlert show];
                }];
            });

            it(@"should find the most recently shown alert view", ^{
                isAlertVisible() should be_truthy;
            });

            context(@"after dismissing the alert view", ^{
                beforeEach(^{
                    tapOn(theFirstView(withLabel(@"Cancel")));
                });

                it(@"should show the previous alert view", ^{
                    isAlertVisible() should be_truthy;
                });
            });

            context(@"after dismissing all the alert views", ^{
                beforeEach(^{
                    tapOn(theFirstView(withLabel(@"Cancel")));
                    tapOn(theFirstView(withLabel(@"Cancel")));
                });

                it(@"should know that no alert views are visible", ^{
                    isAlertVisible() should be_falsy;
                });
            });
        });
    });
});

SPEC_END
