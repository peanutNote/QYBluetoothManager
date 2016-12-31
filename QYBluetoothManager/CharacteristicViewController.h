//
//  CharacteristicViewController.h
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYPeripheralManager;

@interface CharacteristicViewController : UIViewController

@property (nonatomic, strong) QYPeripheralManager *peripheralManager;

@end
