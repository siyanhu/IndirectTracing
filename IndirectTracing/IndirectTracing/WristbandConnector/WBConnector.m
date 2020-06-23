//
//  WBConnector.m
//  IndirectTracing
//
//  Created by HU Siyan on 23/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "WBConnector.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LogTool.h"

@interface WBConnector () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    dispatch_queue_t blequeue;
}

@property (nonatomic, strong) CBCentralManager *blemanager;
@property (nonatomic, strong) CBPeripheral *connectedwb;

@end

@implementation WBConnector

static NSString *WB_ERROR_TAG = @"WBCONNECTOR_ERROR";
static NSString *PUBLIC_SERVICE_ID = @"0x00";
static NSString *WRITTABLE_SERVICE_ID = @"0x00";
static NSString *READONLY_SERVICE_ID = @"0x00";

- (id)initWBConnector:(NSString *)identity {
    self = [super init];
    if (self) {
        blequeue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 1);
        self.blemanager = [[CBCentralManager alloc]initWithDelegate:self queue:blequeue options:@{
            CBCentralManagerScanOptionAllowDuplicatesKey: @NO,
            CBCentralManagerOptionRestoreIdentifierKey: @"tester"
        }];
        return self;
    }
    return nil;
}

#pragma mark - CBCentralManager Delegate
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString *error_message = @"";
    switch(central.state) {
        case CBManagerStateUnknown:
            error_message = @"CBManagerStateUnknown";
            [LogTool controllog:WB_ERROR_TAG content:error_message];
            break;
        case CBManagerStateResetting:
            error_message = @"CBManagerStateResetting";
            [LogTool controllog:WB_ERROR_TAG content:error_message];
            break;
        case CBManagerStateUnsupported:
            error_message = @"CBManagerStateUnsupported";
            [LogTool controllog:WB_ERROR_TAG content:error_message];
            break;
        case CBManagerStateUnauthorized:
            error_message = @"CBManagerStateUnauthorized";
            [LogTool controllog:WB_ERROR_TAG content:error_message];
            break;
        case CBManagerStatePoweredOff:
            error_message = @"CBManagerStatePoweredOff";
            [LogTool controllog:WB_ERROR_TAG content:error_message];
            break;
        case CBManagerStatePoweredOn:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    NSDictionary *info = advertisementData;
    if (!info) {
        return;
    }
    NSArray *serviceUUIDs = [info objectForKey:@"kCBAdvDataHashedServiceUUIDs"];
    for (CBUUID *serviceUUID in serviceUUIDs) {
        if ([serviceUUID.UUIDString isEqualToString:PUBLIC_SERVICE_ID]) {
            [central connectPeripheral:peripheral options:nil];
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [self.blemanager stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:PUBLIC_SERVICE_ID]]];

}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {

}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    NSLog(@"Central Restore: %@ %lu", dict.description, (unsigned long)peripherals.count);
    if (!self.connectedwb) {
//        self.peripherals = [NSMutableArray arrayWithArray:peripherals];
    }
}

#pragma mark - CBPeripheral Delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"BLEReceiver error: %@", [error description]);
        return;
    }

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    for (CBService *service in peripheral.services) {
        [self parseCharacters:service fromPeripheral:peripheral];
    }
}

#pragma mark - Private Functions
- (void)parseCharacters:(CBService *)service fromPeripheral:(CBPeripheral *)peripheral {
    if (!service) {
        return;
    }
    NSArray *characters = [service characteristics];
    if (!characters) {
        return;
    }
    if (![characters count]) {
        return;
    }
    
    NSString *response = @"02 00 0B 00 00 00 01 10 82 10 83 04 05 06 00 00 03";
    [self writeResponse:response toService:service fromPeripheral:peripheral];
}

- (void)writeResponse:(NSString *)message toService:(CBService *)service fromPeripheral:(CBPeripheral *)peripheral {
//    const char* byte = [message cStringUsingEncoding:[NSString defaultCStringEncoding]];
//    NSUInteger length = sizeof(byte)/sizeof(char);
//    NSData *data = [NSData dataWithBytes:&byte length:length];
    NSData *data = [self dataWithStringHex:message];
    CBUUID *uuid_char = [CBUUID UUIDWithString:WRITTABLE_SERVICE_ID];
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:uuid_char service:service];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)readContentFromService:(CBService *)service fromPeripheral:(CBPeripheral *)peripheral {
    
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID.UUIDString isEqualToString:UUID.UUIDString]) {
            return c;
        }
    }
    return nil;
}

- (NSData *)dataWithStringHex:(NSString *)string {
    NSString *cleanString;
    cleanString = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@">" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSInteger length = [cleanString length];
    uint8_t buffer[length/2];
    for (NSInteger i = 0; i < length; i+=2) {
        unsigned result = 0;
        NSScanner *scanner = [NSScanner scannerWithString:[cleanString substringWithRange:NSMakeRange(i, 2)]];
        [scanner scanHexInt:&result];
        buffer[i/2] = result;
    }
    return  [[NSMutableData alloc] initWithBytes:&buffer   length:length/2];
    
}


@end
