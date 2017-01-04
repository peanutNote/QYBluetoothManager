//
//  QYBluetoothManager.h
//  QYBluetoothPrint
//
//  Created by qianye on 16/12/7.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYPeripheralManager.h"
@class QYBluetoothManager;

@protocol QYBluetoothManagerDelegate <NSObject>

- (void)centralManagerDidUpdate:(QYBluetoothManager *)manager;

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didDiscoverPeripheral:(CBPeripheral *)peripheral;

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didConnectedPeripheral:(QYPeripheralManager *)peripheralManager;
- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end

@interface QYBluetoothManager : NSObject

#pragma mark - property

@property (nonatomic, weak) id<QYBluetoothManagerDelegate> delegate;

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) NSMutableArray *peripherals;

@property (nonatomic, strong) NSMutableArray *peripheralsAD;
// 筛选过滤指定服务的外设
@property (nonatomic, strong) NSArray *filterServices;
// 连接成功的外设管理对象
@property (nonatomic, strong) QYPeripheralManager *peripheralManager;

+ (QYBluetoothManager *)shareBluetoothManager;

- (void)connectToPeripheral:(CBPeripheral *)peripheral;

// 开始扫描外设
- (void)startScanPeripheral;
// 停止扫描外设
- (void)stopScanPeripheral;
// 取消连接
- (void)cancelPeripheralConnection;

@end
