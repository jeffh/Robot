#import "Robot.h"
#import "SampleViewController.h"
#import "UIView+RBTouch.h"
#import "RBAnimation.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBKeyboardSpec)

describe(@"RBKeyboard", ^{
    __block SampleViewController *controller;
    __block id<UITextFieldDelegate> textDelegate;

    beforeEach(^{
        textDelegate = nice_fake_for(@protocol(UITextFieldDelegate));
        textDelegate reject_method(@selector(textFieldShouldBeginEditing:));
        textDelegate reject_method(@selector(textFieldShouldEndEditing:));
        textDelegate stub_method(@selector(textField:shouldChangeCharactersInRange:replacementString:)).and_return(YES);

        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
        controller.textField.delegate = textDelegate;
        [UIWindow windowForTesting].rootViewController = controller;
    });

    afterEach(^{
        controller.textField.delegate = nil;
    });

    describe(@"becoming first responder", ^{
        beforeEach(^{
            [controller.textField isFirstResponder] should be_falsy;
            [controller.textField becomeFirstResponder];
        });

        it(@"should become focused", ^{
            controller.textField.isFirstResponder should be_truthy;
        });
    });

    describe(@"typing in a text field", ^{
        beforeEach(^{
            tapOn(controller.textField);
        });

        it(@"should tell the delegate", ^{
            textDelegate should have_received(@selector(textFieldDidBeginEditing:));
        });

        context(@"vanilla keyboard settings", ^{
            it(@"should accept keyboard input", ^{
                [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
                controller.textField.text should equal(@"hello world!");
            });

            it(@"should tell the delegate", ^{
                [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
                textDelegate should have_received(@selector(textField:shouldChangeCharactersInRange:replacementString:));
            });
        });

        context(@"capitalized keyboard settings", ^{
            beforeEach(^{
                controller.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            });

            it(@"should ignore the capitalization rules", ^{
                [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
                controller.textField.text should equal(@"hello world!");
            });
        });
    });

    describe(@"dismissing a keyboard", ^{
        beforeEach(^{
            tapOn(controller.textField);
            [[RBKeyboard mainKeyboard] dismiss];
        });

        it(@"should tell the delegate", ^{
            textDelegate should have_received(@selector(textFieldDidEndEditing:));
        });
    });
});

SPEC_END
