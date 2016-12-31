//
//  QYPeripheralManager.h
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "QYPrinterManager.h"
@class QYPeripheralManager;

@protocol QYPeripheralManager <NSObject>

- (void)peripheralManager:(QYPeripheralManager *)peripheralManager didDiscoverServices:(NSError *)error;

- (void)peripheralManager:(QYPeripheralManager *)peripheralManager didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

@end

@interface QYPeripheralManager : NSObject

@property (nonatomic, weak) id<QYPeripheralManager> delegate;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
// 打印管理对象
@property (nonatomic, strong) QYPrinterManager *printerManager;

- (void)startScanServices;

- (void)stratScanCharacteristics;

@end
