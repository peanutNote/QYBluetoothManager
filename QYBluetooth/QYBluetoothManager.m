//
//  QYBluetoothManager.m
//  QYBluetoothPrint
//
//  Created by qianye on 16/12/7.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "QYBluetoothManager.h"

static QYBluetoothManager *bluetoothManager;

@interface QYBluetoothManager () <CBCentralManagerDelegate>

@end

@implementation QYBluetoothManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothManager = [super allocWithZone:zone];
    });
    return bluetoothManager;
}

+ (QYBluetoothManager *)shareBluetoothManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bluetoothManager = [[QYBluetoothManager alloc] init];
    });
    return bluetoothManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] init];
        _peripheralManager = [[QYPeripheralManager alloc] init];
        _peripherals = [NSMutableArray array];
        _peripheralsAD = [NSMutableArray array];
    }
    return self;
}

- (void)addDiscoverPeripheral:(CBPeripheral *)peripheral peripheralAD:(NSDictionary *)peripheralAD {
    if (![_peripherals containsObject:peripheral]) {
        [_peripherals addObject:peripheral];
        [_peripheralsAD addObject:peripheralAD];
    }
}

- (void)connectToPeripheral:(CBPeripheral *)peripheral {
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    [_centralManager connectPeripheral:peripheral options:connectOptions];
}

- (void)cancelPeripheralConnection {
    [_centralManager cancelPeripheralConnection:_peripheralManager.peripheral];
    _peripheralManager.peripheral = nil;
}

- (void)startScanPeripheral {
    _centralManager.delegate = self;
}

- (void)stopScanPeripheral {
    
}

- (void)stopScanServices {
    [_centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (_delegate && [_delegate respondsToSelector:@selector(centralManagerDidUpdate:)]) {
        [_delegate centralManagerDidUpdate:self];
    }
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            NSMutableArray *services = [NSMutableArray array];
            for (NSString *filterString in _filterServices) {
                CBUUID *uuid = [CBUUID UUIDWithString:filterString];
                [services addObject:uuid];
            }
            [_centralManager scanForPeripheralsWithServices:(services ? : nil) options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        }
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name.length > 0) {
        [self addDiscoverPeripheral:peripheral peripheralAD:advertisementData];
        if (_delegate && [_delegate respondsToSelector:@selector(bluetoothManager:didDiscoverPeripheral:)]) {
            [_delegate bluetoothManager:self didDiscoverPeripheral:peripheral];
        }
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _peripheralManager.peripheral = peripheral;
    if (_delegate && [_delegate respondsToSelector:@selector(bluetoothManager:didConnectedPeripheral:)]) {
        [_delegate bluetoothManager:self didConnectedPeripheral:_peripheralManager];
    }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(bluetoothManager:didFailToConnectPeripheral:error:)]) {
        [_delegate bluetoothManager:self didFailToConnectPeripheral:peripheral error:error];
    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(bluetoothManager:didDisconnectPeripheral:error:)]) {
        [_delegate bluetoothManager:self didDisconnectPeripheral:peripheral error:error];
    }
}

@end
