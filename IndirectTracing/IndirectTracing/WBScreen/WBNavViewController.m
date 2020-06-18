//
//  WBNavViewController.m
//  IndirectTracing
//
//  Created by HU Siyan on 17/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "WBNavViewController.h"

@interface WBNavViewController ()

@end

@implementation WBNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Shown");
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
