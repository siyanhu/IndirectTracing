//
//  WBViewController.m
//  IndirectTracing
//
//  Created by HU Siyan on 17/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "WBViewController.h"
#import "WBConnector.h"
@interface WBViewController ()
@property(strong,nonatomic) WBConnector *WristBand;
@end

@implementation WBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"initWB");
    self.WristBand= [[WBConnector alloc] initWBConnector:@"test"];
//    [self.WristBand startScanPeripheral];
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
