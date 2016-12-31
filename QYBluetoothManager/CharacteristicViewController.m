//
//  CharacteristicViewController.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "CharacteristicViewController.h"
#import "QYBluetoothManager.h"
#import "PrinterViewController.h"

@interface CharacteristicViewController () <UITableViewDelegate, UITableViewDataSource, QYPeripheralManager>

@end

@implementation CharacteristicViewController {
    UITableView *_tableView;
    NSMutableArray *_serviceTitle;
    NSMutableDictionary *_characteristicsDict;
}

#pragma mark - ViewController Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _serviceTitle = [NSMutableArray array];
    _characteristicsDict = [NSMutableDictionary dictionary];
    [self mmInitViews];
    if (_peripheralManager) {
        _peripheralManager.delegate = self;
        [_peripheralManager startScanServices];
    }
}

#pragma mark - initViews

- (void)mmInitViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _serviceTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *services = [_characteristicsDict objectForKey:_serviceTitle[section]];
    return services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"characteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    CBCharacteristic *characteristic = [[_characteristicsDict objectForKey:_serviceTitle[indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",characteristic.UUID];
    cell.detailTextLabel.text = characteristic.description;
    return cell;
}

#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBCharacteristic *characteristic = [[_characteristicsDict objectForKey:_serviceTitle[indexPath.section]] objectAtIndex:indexPath.row];
    [QYBluetoothManager shareBluetoothManager].peripheralManager.characteristic = characteristic;
    PrinterViewController *vc = [[PrinterViewController alloc] init];
    vc.title = [NSString stringWithFormat:@"%@",characteristic.UUID];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _serviceTitle[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    title.text = [NSString stringWithFormat:@"%@", _serviceTitle[section]];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor darkGrayColor]];
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

#pragma mark - QYPeripheralManager

- (void)peripheralManager:(QYPeripheralManager *)peripheralManager didDiscoverServices:(NSError *)error {
    if (error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@查找服务失败！ 原因：%@", peripheralManager.peripheral.name, [error localizedDescription]]];
        return;
    }
    // 开始扫描外设特征
    [peripheralManager stratScanCharacteristics];
}

- (void)peripheralManager:(QYPeripheralManager *)peripheralManager didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@查找特征失败！原因：%@", service.UUID, [error localizedDescription]]];
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSMutableArray *tempArray = [_characteristicsDict objectForKey:service.UUID];
        if (tempArray) {
            [tempArray addObject:characteristic];
        } else {
            [_serviceTitle addObject:service.UUID];
            tempArray = [NSMutableArray arrayWithObject:characteristic];
            [_characteristicsDict setObject:tempArray forKey:service.UUID];
        }
    }
    [_tableView reloadData];
}

@end
