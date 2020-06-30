//
//  WBConnector.h
//  IndirectTracing
//
//  Created by HU Siyan on 23/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN

@interface WBConnector : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
- (id)initWBConnector:(NSString *)identity;
-(void)startScanPeripheral;
@end

NS_ASSUME_NONNULL_END
