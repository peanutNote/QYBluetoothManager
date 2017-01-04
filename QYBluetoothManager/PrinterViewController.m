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
    _titles = @[@"标签运单一体化", @"精简表格", @"80mm打印", @"位图打印测试"];
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
    } else if (indexPath.section == 1) {
        [self printDemoTwo];
    } else if (indexPath.section == 2) {
        [self printDemoThree];
    } else if (indexPath.section == 3) {
        [self printDemoFour];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0;
}

#pragma mark - Print

#pragma mark printDemoOne

- (void)printDemoOne {
    int x_end = 600;
    int y_start = 10;
    int y_end = 350;
    int text_size_height = 24;
    int text_padding = 6;
    
    // 初始化打印
    [_printerManager printerManagerInitData];
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

#pragma mark printDemoTwo

- (void)printDemoTwo {
    [_printerManager printerManagerInitData];
    [_printerManager printFroTemplateWithStrings:@[@"车满满", @"提货联"]
                             atPositions:@[@(0),@(_printerManager.rateOfPtAndPage * (_printerManager.printPageWidth - 8))]
                           withAlighType:@[@(QYPrinterAlignLeft),@(QYPrinterAlignRight)]
                                fontSize:QYPrinterFontSizeNormal
                                fontType:QYPrinterFontType24
                                  isBold:YES];
    [_printerManager printLineType:@"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"];
    [self printFroTemplateWithStrings:@[@"运单号：N10086", @"2017年01月04日"] isBold:NO];
    [self printFroTemplateWithStrings:@[@"发货人：冯爷", @"电话：17086440327"] isBold:NO];
    [_printerManager printLineType:@"┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"];
    [self printFroTemplateWithStrings:@[@"收货人：斗哥", @"电话：15011263633"] isBold:NO];
    [self printFroTemplateWithStrings:@[@"地址：诺安基金大厦"] isBold:NO];
    [_printerManager printLineType:@"┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"];
    [self printFroTemplateWithStrings:@[@"苹果7 100件", @"自提", @"回单100份"] isBold:NO];
    [_printerManager printLineType:@"┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"];
    [self printFroTemplateWithStrings:@[@"现付：1000元", @"到付：100元"] isBold:NO];
    [self printFroTemplateWithStrings:@[@"代收货款：50元", @"报价声明：60元"] isBold:NO];
    [_printerManager printLineType:@"┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫"];
    [self printFroTemplateWithStrings:@[@"发站：北京", @"到站：上海"] isBold:NO];
    [self printFroTemplateWithStrings:@[@"备注：我买着吃的"] isBold:NO];
    [_printerManager printLineType:@"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"];
    [_printerManager printBarCode:@"1110321108" wihtHeight:50];
//    [_printerManager printQRCode:@"http://www.baidu.com" width:80];
    [_printerManager printAllData];
}

- (void)printFroTemplateWithStrings:(NSArray *)strings isBold:(BOOL)isBold {
    NSInteger rightPosition = _printerManager.rateOfPtAndPage * (_printerManager.printPageWidth - 8) - 4;
    NSArray *positions = @[];
    NSArray *alighTypes = @[];
    switch (strings.count) {
        case 0:
            positions = @[@(0), @(rightPosition)];
            alighTypes = @[@(QYPrinterAlignLeft), @(QYPrinterAlignRight)];
            break;
        case 1:
            positions = @[@(0), @(_printerManager.rateOfPtAndPage * 4), @(rightPosition)];
            alighTypes = @[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft), @(QYPrinterAlignRight)];
            break;
        case 2:
            positions = @[@(0), @(_printerManager.rateOfPtAndPage * 4), @(_printerManager.rateOfPtAndPage * (_printerManager.printPageWidth - 16)), @(rightPosition)];
            alighTypes = @[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft), @(QYPrinterAlignRight), @(QYPrinterAlignRight)];
            
            break;
        case 3:
            positions = @[@(0), @(_printerManager.rateOfPtAndPage * 4), @(_printerManager.rateOfPtAndPage * 35), @(_printerManager.rateOfPtAndPage * (_printerManager.printPageWidth - 16)), @(rightPosition)];
            alighTypes = @[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft), @(QYPrinterAlignCenter), @(QYPrinterAlignRight), @(QYPrinterAlignRight)];
            break;
        default:
            break;
    }
    NSMutableArray *printArray = [NSMutableArray array];
    [printArray addObject:@"┃"];
    for (NSString *string in strings) {
        [printArray addObject:string];
    }
    [printArray addObject:@"┃"];
    [_printerManager printFroTemplateWithStrings:printArray
                                     atPositions:positions
                                   withAlighType:alighTypes
                                        fontSize:QYPrinterFontSizeNormal
                                        fontType:QYPrinterFontType24
                                          isBold:isBold];
}

#pragma mark printDemoThree

- (void)printDemoThree {
    [_printerManager printerManagerInitData];
    
    [_printerManager printString:@"车满满" alignType:QYPrinterAlignCenter fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"------ 提货联 ------" alignType:QYPrinterAlignCenter fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printLineType:@"-----------------------------------------------"];
    [_printerManager printString:@"运单号：N10086" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"货号：100" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"北京-湖北武汉" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"开单日期:2017年01月04日" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"会员号：10086" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    
    [_printerManager printString:@"发货人：冯爷" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"电话：15011263633" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"发货地址：诺安基金大厦" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    
    [_printerManager printString:@"收货人：斗哥" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"电话：15011263633" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"收货地址：诺安基金大厦" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    
    [_printerManager printLineType:@"-----------------------------------------------"];
    [_printerManager printString:@"货物名称：苹果7" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"件数：100" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printFroTemplateWithStrings:@[@"重量：15吨", @"体积：10立方米"] atPositions:@[@(0),@(45 * _printerManager.rateOfPtAndPage)] withAlighType:@[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft)] fontSize:QYPrinterFontSizeNormal fontType:QYPrinterFontType24 isBold:NO];
    [_printerManager printFroTemplateWithStrings:@[@"回单：15份", @"送货方式：自提"] atPositions:@[@(0),@(45 * _printerManager.rateOfPtAndPage)] withAlighType:@[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft)] fontSize:QYPrinterFontSizeNormal fontType:QYPrinterFontType24 isBold:NO];
    [_printerManager printString:@"包装：纸盒" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"运输方式：航空" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    
    [_printerManager printLineType:@"-----------------------------------------------"];
    [_printerManager printFroTemplateWithStrings:@[@"运费：", @"55元"] atPositions:@[@(0),@(45 * _printerManager.rateOfPtAndPage)] withAlighType:@[@(QYPrinterAlignLeft), @(QYPrinterAlignLeft)] fontSize:QYPrinterFontSizeNormal fontType:QYPrinterFontType24 isBold:NO];
    [_printerManager printString:@"合计费用：￥100元" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"现付：12元" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"代收货款：￥0元" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"备注：我买来用来吃的" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType32 fontSize:QYPrinterFontSizeNormal isBold:YES];
    [_printerManager printString:@"运输条款：姬收到了贵金属的离开刚好是大了\n看过你死定了卡号急死了都看好就挂上\n了看到过急死了都看过就" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
     [_printerManager printString:@"无锡市地址：光华路" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
     [_printerManager printString:@"联系电话：15011263633" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"北京市地址：光华路" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printString:@"联系电话：15011263633" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printLineType:@"-----------------------------------------------"];
    [_printerManager printString:@"经办人签字：张章" alignType:QYPrinterAlignLeft fontType:QYPrinterFontType24 fontSize:QYPrinterFontSizeNormal isBold:NO];
    [_printerManager printBarCode:@"1110321108" wihtHeight:50];
    [_printerManager printQRCode:@"http://www.baidu.com" width:80];
    [_printerManager cutPage];  // 打印切纸
    [_printerManager printAllData];

}

#pragma mark printDemoFour

- (void)printDemoFour {
    [_printerManager printerManagerInitData];
    [_printerManager printXprinterStandardTemplate];
    [_printerManager printAllData];
}

@end
