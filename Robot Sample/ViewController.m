//
//  ViewController.m
//  Robot Sample
//
//  Created by Jeff Hui on 11/14/14.
//  Copyright (c) 2014 Jeff Hui. All rights reserved.
//

#import "ViewController.h"
#import "RBKeyboard.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.alphaText becomeFirstResponder];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[RBKeyboard mainKeyboard] typeString:@"hello world!"];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
