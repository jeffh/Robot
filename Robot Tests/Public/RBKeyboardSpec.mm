#import "Robot.h"
#import "SampleViewController.h"
#import "RBTimeLapse.h"
#import "NotificationRecorder.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBKeyboardSpec)

describe(@"RBKeyboard", ^{
    __block SampleViewController *controller;
    __block id<UITextFieldDelegate> textDelegate;
    __block UIWindow *window;
    __block NotificationRecorder *notificationRecorder;

    beforeEach(^{
        textDelegate = nice_fake_for(@protocol(UITextFieldDelegate));
        textDelegate reject_method(@selector(textFieldShouldBeginEditing:));
        textDelegate reject_method(@selector(textFieldShouldEndEditing:));
        textDelegate stub_method(@selector(textFieldShouldClear:)).and_return(YES);
        textDelegate stub_method(@selector(textField:shouldChangeCharactersInRange:replacementString:)).and_return(YES);

        notificationRecorder = [[NotificationRecorder alloc] init];
        [notificationRecorder observeNotificationName:UIKeyboardWillChangeFrameNotification];
        [notificationRecorder observeNotificationName:UIKeyboardDidChangeFrameNotification];
        [notificationRecorder observeNotificationName:UIKeyboardWillHideNotification];
        [notificationRecorder observeNotificationName:UIKeyboardDidHideNotification];
        [notificationRecorder observeNotificationName:UIKeyboardWillShowNotification];
        [notificationRecorder observeNotificationName:UIKeyboardDidShowNotification];

        controller = [[SampleViewController alloc] init];
        controller.view should_not be_nil;
        controller.textField.delegate = textDelegate;

        window = [UIWindow createWindowForTesting];
        window.rootViewController = controller;
    });

    afterEach(^{
        [[RBKeyboard mainKeyboard] dismiss];
        for (UIView *subview in [window.subviews copy]) {
            [subview removeFromSuperview];
        }
        window = nil;
        notificationRecorder = nil;
    });

    it(@"should be hidden", ^{
        [[RBKeyboard mainKeyboard] isVisible] should be_falsy;
    });

    describe(@"becoming first responder", ^{
        beforeEach(^{
            [controller.textField isFirstResponder] should be_falsy;
            [RBTimeLapse disableAnimationsInBlock:^{
                [controller.textField becomeFirstResponder];
            }];
        });

        it(@"should become focused", ^{
            controller.textField.isFirstResponder should be_truthy;
        });

        it(@"should be visible", ^{
            [[RBKeyboard mainKeyboard] isVisible] should be_truthy;
        });

        it(@"should trigger NSNotifications", ^{
            notificationRecorder.notificationNames should contain(UIKeyboardWillShowNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardWillChangeFrameNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardDidChangeFrameNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardDidShowNotification);
            notificationRecorder.notificationNames should_not contain(UIKeyboardWillHideNotification);
            notificationRecorder.notificationNames should_not contain(UIKeyboardDidHideNotification);
        });
    });

    describe(@"typing in a number text field", ^{
        beforeEach(^{
            controller.textField.keyboardType = UIKeyboardTypeDecimalPad;
            tapOn(controller.textField); // sadly logs in iOS 8
            [[RBKeyboard mainKeyboard] typeString:@"123"];
        });

        it(@"should accept numbers", ^{
            controller.textField.text should equal(@"123");
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
            [notificationRecorder.notifications removeAllObjects];

            [[RBKeyboard mainKeyboard] dismiss];
        });

        it(@"should not tell the delegate", ^{
            // dismissing a keyboard does not remove it's firstResponder status
            textDelegate should_not have_received(@selector(textFieldDidEndEditing:));
        });

        it(@"should indicate the keyboard is invisible", ^{
            [[RBKeyboard mainKeyboard] isVisible] should be_falsy;
        });

        it(@"should trigger NSNotifications", ^{
            notificationRecorder.notificationNames should_not contain(UIKeyboardWillShowNotification);
            notificationRecorder.notificationNames should_not contain(UIKeyboardDidShowNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardWillChangeFrameNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardDidChangeFrameNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardWillHideNotification);
            notificationRecorder.notificationNames should contain(UIKeyboardDidHideNotification);
        });

    });
});

SPEC_END
