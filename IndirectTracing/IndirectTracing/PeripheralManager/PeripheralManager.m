//
//  PeripheralManager.m
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "PeripheralManager.h"
#include <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralManager () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    dispatch_queue_t cbcQueue;
}

@property (nonatomic, strong) CBCentralManager *manager;

@end

@implementation PeripheralManager

- (id)initPeripheralManager {
    self = [super init];
    if (self) {
        cbcQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 1);
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:cbcQueue options:@{
                CBCentralManagerOptionRestoreIdentifierKey: @"vtlib.central",
                CBCentralManagerScanOptionAllowDuplicatesKey: @NO
        }];
        return self;
    }
    return nil;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *strMessage = @"";
    NSString *buttonTitle = nil;
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            NSLog(@"Success: bluetooth turned on");
            return;
        }
            break;
        case CBManagerStateUnknown: {
            strMessage = @"手机没有识别到蓝牙，请检查手机。";
            buttonTitle = @"前往设置";
        }
            break;
        case CBManagerStateResetting: {
            strMessage = @"手机蓝牙已断开连接，重置中...";
            buttonTitle = @"前往设置";
        }
            break;
        case CBManagerStateUnsupported: {
            strMessage = @"手机不支持蓝牙功能，请更换手机。";
        }
            break;
        case CBManagerStatePoweredOff: {
            strMessage = @"手机蓝牙功能关闭，请前往设置打开蓝牙及控制中心打开蓝牙。";
            buttonTitle = @"前往设置";
        }
            break;
        case CBManagerStateUnauthorized: {
            strMessage = @"手机蓝牙功能没有权限，请前往设置。";
            buttonTitle = @"前往设置";
        }
            break;
        default: { }
            break;
    }
    //通知没有打开蓝牙的自定义提示弹窗（弹窗代码自行实现）
   // [self __broadAlertMessage:strMessage buttonTitle:buttonTitle];
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    
}

@end
