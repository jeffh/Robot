#import "Robot.h"
#import "SampleViewController.h"
#import "RBTimeLapse.h"


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
        textDelegate stub_method(@selector(textFieldShouldClear:)).and_return(YES);
        textDelegate stub_method(@selector(textField:shouldChangeCharactersInRange:replacementString:)).and_return(YES);

        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
        controller.textField.delegate = textDelegate;
        [UIWindow createWindowForTesting].rootViewController = controller;
    });

    afterEach(^{
        [[RBKeyboard mainKeyboard] dismiss];
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

    describe(@"typing in a number text field", ^{
        beforeEach(^{
            controller.textField.keyboardType = UIKeyboardTypeDecimalPad;
            tapOn(controller.textField);
        });
    });

    describe(@"typing in a text field", ^{
        beforeEach(^{
            tapOn(controller.textField);
        });

        it(@"should tell the delegate", ^{
            textDelegate should have_received(@selector(textFieldDidBeginEditing:));
        });

        it(@"should say the keyboard is visible", ^{
            [[RBKeyboard mainKeyboard] isVisible] should be_truthy;
        });

        context(@"vanilla keyboard settings", ^{
            beforeEach(^{
                [[RBKeyboard mainKeyboard] typeString:@"héllo world!"];
            });

            it(@"should accept keyboard input", ^{
                controller.textField.text should equal(@"héllo world!");
            });

            it(@"should tell the delegate", ^{
                textDelegate should have_received(@selector(textField:shouldChangeCharactersInRange:replacementString:));
            });
        });

        describe(@"clearing text", ^{
            beforeEach(^{
                [[RBKeyboard mainKeyboard] typeString:@"hello"];
                [[RBKeyboard mainKeyboard] clearText];
            });

            it(@"should fire the delegate methods on the text field", ^{
                textDelegate should have_received(@selector(textFieldShouldClear:));
            });

            it(@"should be able to clear the entered text", ^{
                [[RBKeyboard mainKeyboard] clearText];
                controller.textField.text should be_empty;
            });
        });

        context(@"capitalized keyboard settings", ^{
            beforeEach(^{
                controller.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
            });

            it(@"should ignore the capitalization rules", ^{
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

        it(@"should indicate the keyboard is invisible", ^{
            [[RBKeyboard mainKeyboard] isVisible] should be_falsy;
        });
    });
});

SPEC_END
