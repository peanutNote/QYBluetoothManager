//
//  QYPeripheralManager.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "QYPeripheralManager.h"

@interface QYPeripheralManager () <CBPeripheralDelegate, QYPrinterManagerDelegate>

@end

static const NSInteger MAX_PRINT_STR_LENGTH = 150;

@implementation QYPeripheralManager

- (instancetype)init {
    if (self = [super init]) {
        _printerManager = [[QYPrinterManager alloc] init];
        _printerManager.delegate = self;
    }
    return self;
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    _peripheral.delegate = self;
}

- (void)startScanServices {
    if (_peripheral) {
        [_peripheral discoverServices:nil];
    }
}

- (void)stratScanCharacteristics {
    if (_peripheral) {
        for (CBService *service in _peripheral.services) {
            [_peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(peripheralManager:didDiscoverServices:)]) {
        [_delegate peripheralManager:self didDiscoverServices:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(peripheralManager:didDiscoverCharacteristicsForService:error:)]) {
        [_delegate peripheralManager:self didDiscoverCharacteristicsForService:service error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

#pragma mark - QYPrinterManagerDelegate

- (void)printData:(NSData *)data {
    if (_peripheral && _characteristic) {
        NSInteger count = 0;
        while (count * MAX_PRINT_STR_LENGTH < data.length) {
            NSUInteger length = data.length - count * MAX_PRINT_STR_LENGTH;
            if (length > MAX_PRINT_STR_LENGTH) {
                length = MAX_PRINT_STR_LENGTH;
            }
            NSData *printData = [data subdataWithRange:NSMakeRange(count * MAX_PRINT_STR_LENGTH, length)];
            if(_characteristic.properties & CBCharacteristicPropertyWrite) {
                if (printData && [printData isKindOfClass:[NSData class]]) {
                    [_peripheral writeValue:printData forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
                }
            } else {
                [SVProgressHUD showErrorWithStatus:@"该字段不可写！"];
            }
            count++;
        }
    }
}

@end
