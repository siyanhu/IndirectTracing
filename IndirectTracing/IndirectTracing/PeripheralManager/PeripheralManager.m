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
            strMessage = @"No Bluetooth access.";
            buttonTitle = @"Go to settings.";
        }
            break;
        case CBManagerStateResetting: {
            strMessage = @"Bluetooth resetting";
            buttonTitle = @"Go to settings";
        }
            break;
        case CBManagerStateUnsupported: {
            strMessage = @"Bluetooth not supported.";
        }
            break;
        case CBManagerStatePoweredOff: {
            strMessage = @"Bluetooth powered off. Please turn it on.";
            buttonTitle = @"Go to settings.";
        }
            break;
        case CBManagerStateUnauthorized: {
            strMessage = @"Bluetooth not authorised. Please turn it on.";
            buttonTitle = @"Go to settings.";
        }
            break;
        default: { }
            break;
    }
    //通知没有打开蓝牙的自定义提示弹窗（弹窗代码自行实现）
   // [self __broadAlertMessage:strMessage buttonTitle:buttonTitle];
}

@end
