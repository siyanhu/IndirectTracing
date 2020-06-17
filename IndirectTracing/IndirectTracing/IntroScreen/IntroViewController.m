//
//  IntroViewController.m
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "IntroViewController.h"
#import "Localizer.h"
#import "LogTool.h"

@interface IntroViewController () <UITextViewDelegate> {
    BOOL first_access;
}

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* button_down_height;
@property (nonatomic, strong) IBOutlet UITextView *description_textview;
@property (nonatomic, strong) IBOutlet UIButton *buttonup;
@property (nonatomic, strong) IBOutlet UIButton *buttondown;


@end

@implementation IntroViewController
static NSString *INTROVC_ERROR_TAG = @"INTROVC_ERROR";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    first_access = [self preset];
    if (first_access) {
        [self showGetStartedView];
    } else {
        [self showAccessView];
    }
}

#pragma mark - INTRO VIEW
- (BOOL)preset {
    NSDictionary *constants = [[Localizer sharedinstance] readpreset];
    if (!constants) {
        [LogTool controllog:INTROVC_ERROR_TAG content:@"CANNOT FIND CONSTANT DICT"];
        return NO;
    }
    //FIRST_ACCESS
    NSString *fa_str = [constants valueForKey:@"FIRST_ACCESS"];
    BOOL fa = YES;
    if (![fa_str isEqualToString:@"true"])
        fa = NO;
    return fa;
}

- (void)showGetStartedView {
    self.button_down_height.constant = 0;
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    NSString *up_str = [[Localizer sharedinstance] getLocalizedStringFrom:@"FIRST_INTRO_BUTTON_UP" alter:@""];
    [self.buttonup setTitle:up_str forState:UIControlStateNormal];
}

- (void)hideGetStartedView {
    
}

- (void)showAccessView {
    self.button_down_height.constant = 40;
    [self.view updateConstraints];
    [self.view layoutIfNeeded];
    NSString *up_str = [[Localizer sharedinstance] getLocalizedStringFrom:@"SECOND_INTRO_BUTTON_UP" alter:@""];
    [self.buttonup setTitle:up_str forState:UIControlStateNormal];
}

- (void)hideAccessView {
    
}

#pragma mark - IBAction
- (IBAction)buttonup:(id)sender {
    if (first_access) {
        [self hideGetStartedView];
        [self showAccessView];
        [[Localizer sharedinstance] modifypreset:@"FIRST_ACCESS" withContent:@"false"];
    } else {
        
    }
}

- (IBAction)buttondown:(id)sender {
    
}

#pragma mark - Private Functions
- (void)askforBluetoothAccess {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
