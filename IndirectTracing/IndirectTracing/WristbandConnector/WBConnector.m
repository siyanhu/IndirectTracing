//
//  WBConnector.m
//  IndirectTracing
//
//  Created by HU Siyan on 23/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "WBConnector.h"
#import "LogTool.h"

@interface WBConnector () <CBCentralManagerDelegate, CBPeripheralDelegate> {
    dispatch_queue_t blequeue;
    NSTimer *cbcTimer;
}

@property (nonatomic, strong) CBCentralManager *blemanager;
@property (nonatomic, strong) CBPeripheral *connectedwb;
@property (nonatomic,strong) NSString *lastTimeStamp;

@end

@implementation WBConnector

static NSString *WB_ERROR_TAG = @"WBCONNECTOR_ERROR";
static NSString *PUBLIC_SERVICE_ID = @"0000ffa1-0000-1000-8000-00805f9b34fb";
static NSString *WRITTABLE_SERVICE_ID = @"0000ffb1-0000-1000-8000-00805f9b56fb";
static NSString *READONLY_SERVICE_ID = @"0000ffb2-0000-1000-8000-00805f9b56fb";//0x00

bool onceonly=false;



- (id)initWBConnector:(NSString *)identity {
    self = [super init];
    if (self) {
        blequeue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 1);
        self.blemanager = [[CBCentralManager alloc]initWithDelegate:self queue:blequeue options:@{
            CBCentralManagerScanOptionAllowDuplicatesKey: @NO,
            CBCentralManagerOptionRestoreIdentifierKey: @"tester"
        }];
        
        _lastTimeStamp=@"00 00 00 00 00";
        NSLog(@"blemanager created");
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
            NSLog(@"PowerOn");
            [self.blemanager scanForPeripheralsWithServices:nil/*[NSArray arrayWithObject:[CBUUID UUIDWithString:PUBLIC_SERVICE_ID]]*/
            options:@{@"CBCentralManagerScanOptionAllowDuplicatesKey": @YES}];            break;
            
        
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    
    NSDictionary *info = advertisementData;
    if (RSSI.intValue<(-50)){
        return;
    }else {
        NSLog(@"name:%@,RSSI:%@",peripheral.name,RSSI);
    }
    
    if([peripheral.name isEqualToString:@"Tracing_Wristband"] ){
        
        [self.blemanager connectPeripheral:peripheral options:nil];
        self.connectedwb=peripheral;
        self.connectedwb.delegate=self;
        [self.blemanager stopScan];
    }
    
    
//    if (!info) {
//        return;
//    }
//
//    NSArray *serviceUUIDs = [info objectForKey:@"kCBAdvDataHashedServiceUUIDs"];
//    if(serviceUUIDs){
//        NSLog(@"ad:%@",advertisementData);}
    
//    for (CBUUID *serviceUUID in serviceUUIDs) {
//        NSLog(@"serviceUUID",serviceUUID);
//        if ([serviceUUID.UUIDString isEqualToString:PUBLIC_SERVICE_ID]) {
//            [central connectPeripheral:peripheral options:nil];
//            NSLog(@"connected to Peripheral with service UUID");
//            break;
//        }
//    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    
    NSLog(@" connected to peripheral");
    
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
    
    NSLog(@"didDiscoverServices:\n");
    if (error) {
        NSLog(@"BLEReceiver error: %@", [error description]);
        return;
    }else{
        
        for (CBService *service in peripheral.services) {
            NSLog(@"Service found with UUID: %@\n", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    NSLog(@"didDiscoverCHAR");
    for (CBService *service in peripheral.services) {
           
           
            [self writeResponse:_lastTimeStamp toService:service fromPeripheral:peripheral];
        }
//        [self parseCharacters:service fromPeripheral:peripheral];
}


-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didWriteCHAR1");
    [self readContentFromService:characteristic.service fromPeripheral:peripheral];
};

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //read content from char2 FFB2
    NSData *content = characteristic.value;
    NSLog(@"READ :%@",content);
    if (!onceonly) {
        [self readContentFromService:characteristic.service fromPeripheral:peripheral];
        onceonly=(!onceonly);
    }

    
    
    //split data, checksum, update last timestamp, write to write_char;
};

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
    
    NSString *response = @"00 00 00 00 00";
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
    NSLog(@"writeCHAR");
}

- (void)readContentFromService:(CBService *)service fromPeripheral:(CBPeripheral *)peripheral {
    CBUUID *uuid_char = [CBUUID UUIDWithString:READONLY_SERVICE_ID];
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:uuid_char service:service];
    [peripheral readValueForCharacteristic:characteristic];
    
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
