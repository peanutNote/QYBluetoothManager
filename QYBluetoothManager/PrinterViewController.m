//
//  PrinterViewController.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/31.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "PrinterViewController.h"
#import "QYBluetoothManager.h"

@interface PrinterViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PrinterViewController {
    UITableView *_tableView;
    NSArray *_titles;
    QYPrinterManager *_printerManager;
}

#pragma mark - ViewController Method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titles = @[@"打印测试1", @"打印测试2", @"打印测试3"];
    _printerManager = [QYBluetoothManager shareBluetoothManager].peripheralManager.printerManager;
    [self mmInitViews];
}

#pragma mark - initViews

- (void)mmInitViews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - 字符串相关处理

- (NSString *)subStringForOneLine:(NSString *)target max:(int)max {
    NSInteger realMax = max > target.length ? target.length : max;
    int count = 0;
    int specialCount = 0;
    NSInteger subLength = 0;
    while (count < target.length && subLength < realMax) {
        unichar ch = [target characterAtIndex:count];
        if (ch == 10) {
            break;
        }
        if ([[self specialCharacterASCIIForPrint] containsObject:@(ch)]) {
            specialCount++;
            if (specialCount == 2) {
                realMax++;
                specialCount = 0;
            }
        }
        subLength++;
        count++;
    }
    subLength = subLength > target.length ? target.length : subLength;
    return target ? [target substringToIndex:subLength] : @"";
}

- (NSArray *)specialCharacterASCIIForPrint {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 33; i <= 63; i++) {
        [tempArray addObject:@(i)];
    }
    for (int i = 91; i <= 127; i++) {
        [tempArray addObject:@(i)];
    }
    return [tempArray copy];
}

- (NSArray *)subStringForMultipLine:(NSString *)target maxLine:(int)maxLine eachLineSize:(int)eachLineSize {
    NSString *inputString = [target copy];
    NSMutableArray *arrayList = [NSMutableArray array];
    
    for (int i = 0; i < maxLine; i++) {
        NSString *tmp = [self subStringForOneLine:inputString max:eachLineSize];
        [arrayList addObject:tmp];
        inputString = [inputString substringFromIndex:MIN(inputString.length, tmp.length)];
        if (inputString.length == 0) {
            break;
        }
        if ([[inputString substringToIndex:1] isEqualToString:@"\n"]) {
            inputString = [inputString substringFromIndex:1];
        }
    }
    return [arrayList copy];
}

- (NSString *)substring:(NSString *)src length:(NSInteger)length
{
    NSString *dest = @"";
    if (src.length > length) {
        dest = [src substringWithRange:NSMakeRange(0, length)];
    } else {
        dest = src;
    }
    return dest;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _titles[indexPath.section];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self printDemoOne];
    }
}

#pragma mark - Print

- (void)printDemoOne {
    int x_end = 600;
    int y_start = 10;
    int y_end = 350;
    int text_size_height = 24;
    int text_padding = 6;
    
    // 初始化打印
    [_printerManager mPrintInitDataWidth:600 Height:y_end];
    int xCursor = 0;
    int yCursor = y_start;
    
    // 打印公司名
    [_printerManager mPrintTextData:NO
                               font:5
                               size:0
                                  x:xCursor + 100
                                  y:yCursor
                            content:[self substring:@"车满满" length:12]];
    [_printerManager mPrintSetBold:2];
    [_printerManager mPrintTextData:NO font:5 size:0 x:xCursor + 420 y:yCursor content:[NSString stringWithFormat:@"%zd/%zd", 1, 1]];
    [_printerManager mPrintSetBold:0];
    
    xCursor = 0;
    yCursor += (text_size_height + text_padding * 2);
    [_printerManager mPrintLineWithX0:xCursor y0:yCursor x1:x_end y1:yCursor width:1];
    
    // 运单号、发站
    xCursor = 0;
    yCursor += text_padding * 2;
    [_printerManager mPrintSetBold:2];
    [_printerManager mPrintTextData:NO font:5 size:0 x:xCursor y:yCursor content:@"N10086"];
    [_printerManager mPrintSetBold:0];
    [_printerManager mPrintTextData:NO font:5 size:0 x:xCursor + 320 y:yCursor content:[NSString stringWithFormat:@"发站:%@", @"北京"]];
    
    // 到站以及数量
    xCursor = 0;
    yCursor += (text_size_height + text_padding * 2);
    [_printerManager mPrintSetBold:2];
    [_printerManager mPrintSetMAG:3 height:3];
    [_printerManager mPrintTextData:NO font:55 size:0 x:xCursor y:yCursor content:@"湖北"];
    [_printerManager mPrintTextData:NO font:55 size:0 x:xCursor + 320 y:yCursor content:[NSString stringWithFormat:@"%@件", @5]];
    [_printerManager mPrintSetBold:0];
    [_printerManager mPrintSetMAG:0 height:0];
    
    // 发货人信息
    xCursor = 0;
    yCursor += (text_size_height * 2 + text_padding);
    [_printerManager mPrintTextData:NO
                               font:5
                               size:0
                                  x:xCursor
                                  y:yCursor
                            content:[self substring:[NSString stringWithFormat:@"发货人:%@ %@", @"易雄", @17086440327] length:16]];
    
    // 收货人信息
    xCursor = 0;
    yCursor += (text_size_height + text_padding);
    [_printerManager mPrintTextData:NO
                               font:5
                               size:0
                                  x:xCursor
                                  y:yCursor
                            content:[self substring:[NSString stringWithFormat:@"收货人:%@ %@", @"张章", @15011263633] length:16]];
    
    // 货物信息
    xCursor = 0;
    yCursor += (text_size_height + text_padding);
    NSMutableArray *goodsInfo = [NSMutableArray array];
    [goodsInfo addObject:@"冯爷"];
    [goodsInfo addObject:[NSString stringWithFormat:@"回单%zd份", @1]];
    [goodsInfo addObject:[NSString stringWithFormat:@"%@吨", @2]];
    [goodsInfo addObject:[NSString stringWithFormat:@"%@立方米", @3]];
    NSString *goodsString = [goodsInfo componentsJoinedByString:@"/"];
    [_printerManager mPrintTextData:NO
                               font:5
                               size:0
                                  x:xCursor
                                  y:yCursor
                            content:[self substring:goodsString length:16]];
    
    // 费用信息
    xCursor = 0;
    yCursor += (text_size_height + text_padding);
    NSMutableArray *payModeList = [NSMutableArray array];
    [payModeList addObject:[NSString stringWithFormat:@"现付:%@", @11]];
    [payModeList addObject:[NSString stringWithFormat:@"月结:%@", @133]];
    [payModeList addObject:[NSString stringWithFormat:@"回付:%@", @2]];
    NSString *totalPrice = [NSString stringWithFormat:@"%@", @100];
    if (payModeList.count) {
        totalPrice = [NSString stringWithFormat:@"%@(%@)", totalPrice, [payModeList componentsJoinedByString:@","]];
    }
    
    [_printerManager mPrintTextData:NO
                               font:5
                               size:0
                                  x:xCursor
                                  y:yCursor
                            content:[NSString stringWithFormat:@"运费:%@元", [self subStringForOneLine:totalPrice max:18]]];
    
    xCursor = 0;
    yCursor += (text_size_height + text_padding);
    [_printerManager mPrintTextData:NO font:5 size:0 x:xCursor y:yCursor content:[NSString stringWithFormat:@"代收货款:%@元 | %@", @10, @"自提"]];
    
    xCursor = 0;
    yCursor += (text_size_height + text_padding);
    [_printerManager mPrintTextData:NO font:5 size:0 x:xCursor y:yCursor content:[self substring:[NSString stringWithFormat:@"备注:%@", @"傻子"] length:22]];
    
    [_printerManager mPrintQRCode:NO x:400 y:140 content:@"http://www.baidu.com"];
    
    [_printerManager mPrintEnd];
    [_printerManager printAllData];
}

@end
