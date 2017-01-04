//
//  ViewController.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/7.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "ViewController.h"
#import "QYBluetoothManager.h"
#import "CharacteristicViewController.h"

@interface ViewController () <QYBluetoothManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController {
    UITableView *_tableView;
    QYBluetoothManager *_bluetoothManager;
    NSMutableArray *_peripherals;
}

#pragma mark - ViewController Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _peripherals = [NSMutableArray array];
    _bluetoothManager = [QYBluetoothManager shareBluetoothManager];
    _bluetoothManager.delegate = self;
    _bluetoothManager.filterServices = @[@"FFF0", @"18F0", @"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"];
    [_bluetoothManager startScanPeripheral];
    [self mmInitViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_bluetoothManager.peripheralManager.peripheral) {
        [_bluetoothManager cancelPeripheralConnection];
    }
}

#pragma mark - initViews

- (void)mmInitViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
}


-(void)insertTableView:(CBPeripheral *)peripheral {
    if(![_peripherals containsObject:peripheral]) {
        [_peripherals addObject:peripheral];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_peripherals.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"peripheral_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    NSDictionary *ad = [_bluetoothManager.peripheralsAD objectAtIndex:indexPath.row];
    
    NSString *localName;
    if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
        localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
    } else{
        localName = peripheral.name;
    }
    
    cell.textLabel.text = localName;
    //信号和服务
    cell.detailTextLabel.text = @"读取中...";
    //找到cell并修改detaisText
    NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
    if (serviceUUIDs) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)serviceUUIDs.count];
    } else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    [_bluetoothManager connectToPeripheral:peripheral];
    [SVProgressHUD showWithStatus:@"连接中..."];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - QYBluetoothManagerDelegate

- (void)centralManagerDidUpdate:(QYBluetoothManager *)manager {
    
}

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didDiscoverPeripheral:(CBPeripheral *)peripheral {
    [self insertTableView:peripheral];
}

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didConnectedPeripheral:(QYPeripheralManager *)peripheralManager {
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接到名称为（%@）的设备-成功", peripheralManager.peripheral.name]];
    CharacteristicViewController *vc = [[CharacteristicViewController alloc] init];
    vc.peripheralManager = peripheralManager;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"连接到名称为（%@）的设备-失败,原因:%@", [peripheral name], [error localizedDescription]]];
}

- (void)bluetoothManager:(QYBluetoothManager *)bluetoothManager didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
     [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"外设连接断开连接 %@: %@", [peripheral name], [error localizedDescription]]];
}

@end
