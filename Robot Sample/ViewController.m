//
//  ViewController.m
//  Robot Sample
//
//  Created by Jeff Hui on 11/14/14.
//  Copyright (c) 2014 Jeff Hui. All rights reserved.
//

#import "ViewController.h"
#import "RBKeyboard.h"

@interface ViewController () <UITextFieldDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSLog(@"Msg: %@", NSStringFromSelector(_cmd));
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Msg: %@", NSStringFromSelector(_cmd));
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Msg: %@", NSStringFromSelector(_cmd));
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"Msg: %@", NSStringFromSelector(_cmd));
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"Msg: %@", NSStringFromSelector(_cmd));
    return YES;
}

- (void)logNotification:(NSNotification *)notification {
    NSLog(@"Notification: %@", notification.name);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logNotification:) name:UIKeyboardDidShowNotification object:nil];
    self.alphaText.delegate = self;
    [self.alphaText becomeFirstResponder];

    [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
    [[RBKeyboard mainKeyboard] dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
