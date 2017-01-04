//
//  QYPrinterManager.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "QYPrinterManager.h"

#import "QYThermalSupport.h"
#import "MMQRCode.h"

@implementation QYPrinterManager {
    NSMutableData *_bufferData;
    BOOL _isSetBold;            // 是否设置粗体(58mm打印需要)
    BOOL _isSetWidthTwice;      // 是否设置了字体宽放大两倍
}

- (instancetype)init {
    if (self = [super init]) {
        _bufferData = [NSMutableData data];
        _printPageWidth = 79;
        _rateOfPtAndPage = 8;
    }
    return self;
}

- (void)printerManagerInitData {
    _bufferData = [NSMutableData data];
    [_bufferData appendData:[self newLineData]];
    if (_printSize == QYOrderPrintSize80mm) {
        _printPageWidth = 79;
    } else if (_printPageWidth == QYOrderPrintSize58mm) {
        _printPageWidth = 58;
    }
}

- (void)addDataToBuffer:(NSData *)data {
    [_bufferData appendData:data];
}

- (void)printAllData {
    if (_delegate && [_delegate respondsToSelector:@selector(printData:)]) {
        [SVProgressHUD showSuccessWithStatus:@"打印数据已发出"];
        [_delegate printData:_bufferData];
    }
}

#pragma mark 芝柯表格打印(指令集：ZICOX_CPCL)

- (void)mPrintInitDataWidth:(int)width Height:(int)height {
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"! 0 200 200 %d 1\r\n", height]]];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"PAGE-WIDTH %d\r\n", width]]];
}

- (void)mPrintTextData:(BOOL)isVertical font:(int)font size:(int)size x:(int)x y:(int)y content:(NSString *)content {
    NSString *contentString = [NSString stringWithFormat:@"%@ %d %d %d %d %@\r\n", isVertical ? @"T270" : @"T", font, size, x, y, content];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:contentString]];
}

- (void)mPrintLineWithX0:(int)x0 y0:(int)y0 x1:(int)x1 y1:(int)y1 width:(int)width {
    NSString *lineString = [NSString stringWithFormat:@"LINE %d %d %d %d %d\r\n", x0, y0, x1, y1, width];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:lineString]];
}

- (void)mPrintBoxWithX0:(int)x0 y0:(int)y0 x1:(int)x1 y1:(int)y1 width:(int)width {
    NSString *boxString = [NSString stringWithFormat:@"BOX %d %d %d %d %d\r\n", x0, y0, x1, y1, width];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:boxString]];
}

- (void)mPrintSetAlign:(int)align {
    switch (align) {
        case 1:
            [self addDataToBuffer:[self dataUsingEncodeingWithString:@"RIGHT\r\n"]];
            break;
        case 2:
            [self addDataToBuffer:[self dataUsingEncodeingWithString:@"CENTER\r\n"]];
            break;
        default:
            [self addDataToBuffer:[self dataUsingEncodeingWithString:@"LEFT\r\n"]];
            break;
    }
}

- (void)mPrintSetSpeed:(int)level {
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"SPEED %d\r\n", level]]];
}

- (void)mPrintFeed:(BOOL)isFirst length:(int)length {
    NSString *feedString = [NSString stringWithFormat:@"%@ %d\r\n", isFirst ? @"POSTFEED" : @"PREFEED" , length];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:feedString]];
}

- (void)mPrintSetBold:(int)apply {
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"SETBOLD %d\r\n", apply]]];
}

- (void)mPrintSetMAG:(int)width height:(int)height {
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"SETMAG %d %d\r\n", width, height]]];
}

- (void)mPrintSetSpace:(int)space {
    [self addDataToBuffer:[self dataUsingEncodeingWithString:[NSString stringWithFormat:@"SETSP %d\r\n", space]]];
}

- (void)mPrintBarCode:(BOOL)isVertical height:(int)height x:(int)x y:(int)y content:(NSString *)content {
    NSString *barCodeString = [NSString stringWithFormat:@"%@ 128 1 1 %d %d %d %@\r\n", isVertical ? @"VB" : @"B", height, x, y, content];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:barCodeString]];
}

- (void)mPrintQRCode:(BOOL)isVertical x:(int)x y:(int)y content:(NSString *)content {
    NSString *qrCodeString1 = [NSString stringWithFormat:@"%@ QR %d %d M 2 U 4\r\n", isVertical ? @"VB" : @"B", x , y];
    NSString *qrCodeString2 = [NSString stringWithFormat:@"MA,%@\r\n", content];
    NSString *qrCodeString3 = @"ENDQR\r\n";
    [self addDataToBuffer:[self dataUsingEncodeingWithString:qrCodeString1]];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:qrCodeString2]];
    [self addDataToBuffer:[self dataUsingEncodeingWithString:qrCodeString3]];
}

- (void)mPrintEnd {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    [self addDataToBuffer:[@"PRINT\r\n" dataUsingEncoding:enc]];
}

- (NSData*)dataUsingEncodeingWithString:(NSString *)string {
    return [string dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
}

#pragma mark 位图打印

- (void)printDataImage:(UIImage *)image withAlighType:(QYPrinterAlignType)alignType maxWidth:(CGFloat)maxWidth {
    NSMutableData *imageData = [NSMutableData data];
    [imageData appendData:[self printerInitData]];
    [imageData appendData:[self setAlignTypeData:alignType]];
    CGFloat width = image.size.width;
    if (width > maxWidth) {
        CGFloat height = image.size.height;
        CGFloat maxHeight = maxWidth * height / width;
        image = [self createCurrentImage:image width:maxWidth height:maxHeight];
    }
    NSData *data = [QYThermalSupport imageToThermalData:image];
    [imageData appendData:data];
    [imageData appendData:[self newLineData]];
    [imageData appendData:[self newLineData]];
    [imageData appendData:[self newLineData]];
    [imageData appendData:[self newLineData]];
    [self addDataToBuffer:imageData];
}

// 缩放图片
- (UIImage *)createCurrentImage:(UIImage *)inImage width:(CGFloat)width height:(CGFloat)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [inImage drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

#pragma mark - ESC/POS指令打印

#pragma mark 基础指令

- (NSData *)printerInitData {
    Byte bytes[] = {0x1B,0x40};
    return [[NSData alloc] initWithBytes:bytes length:2];
}

- (NSData *)newLineData {
    Byte bytes[] = {0x0A};
    return [[NSData alloc] initWithBytes:bytes length:1];
}

- (NSData *)imageHeaderData {
    Byte bytes[] = {0x1F,0x10,0x30,0x00};
    return [[NSData alloc] initWithBytes:bytes length:4];
}

- (NSData *)underLineData:(Byte)type {
    Byte bytes[] = {0x1C,0x2D,type};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)boldData:(BOOL)enabled {
    Byte bytes[] = {0x1B,0x45,enabled ? 0x01 : 0x00};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)lineSpaceData:(Byte)lineSpace {
    Byte bytes[] = {0x1B,0x33,lineSpace};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)rightMarginData:(Byte)rightMargin {
    Byte bytes[] = {0x1B,0x20,rightMargin};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)leftMarginData:(Byte)leftMargin {
    Byte bytes[] = {0x1B,0x6C,leftMargin};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)absolutePostionDataWithL:(Byte)l h:(Byte)h {
    Byte bytes[] = {0x1B,0x24,l,h};
    return [[NSData alloc] initWithBytes:bytes length:4];
}

- (NSData *)setFontTypeData:(Byte)fontType {
    Byte bytes[] = {0x1B,0x4D,fontType};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)setFontSizeData:(Byte)fontSize {
    Byte bytes[] = {0x1D,0x21,fontSize};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)setAlignTypeData:(Byte)alignType {
    Byte bytes[] = {0x1B,0x61,alignType};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)cutPaperData {
    Byte bytes[] = {0x1D,0x56,0x42,0x20};
    return [[NSData alloc] initWithBytes:bytes length:4];
}

- (NSData *)tabCountData:(Byte)count {
    Byte bytes[] = {0x1B,0x44,count};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)getPrinterStatusData {
    Byte bytes[] = {0x1B,0x76};
    return [[NSData alloc] initWithBytes:bytes length:2];
}

- (NSData *)getPrinterHardwareVersionData {
    Byte bytes[] = {0x1B,0x2B};
    return [[NSData alloc] initWithBytes:bytes length:2];
}

- (NSData *)getPrinterSoftwareVersionData {
    Byte bytes[] = {0x1B,0x2C};
    return [[NSData alloc] initWithBytes:bytes length:2];
}

- (NSData *)setBaudRateData:(Byte)baudRate {
    Byte bytes[] = {0x1B,0x02,baudRate};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

- (NSData *)whitePrintData:(BOOL)enabled {
    Byte bytes[] = {0x1D,0x42,enabled ? 0x01 : 0x00};
    return [[NSData alloc] initWithBytes:bytes length:3];
}

#pragma mark 自定义打印指令

- (void)printString:(NSString *)string
          alignType:(QYPrinterAlignType)alignType
           fontType:(QYPrinterFontType)fontType
           fontSize:(QYPrinterFontSize)fontSize
             isBold:(BOOL)isBold {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self printerInitData]];
    [data appendData:[self setAlignTypeData:alignType]];
    [data appendData:[self setFontTypeData:fontType]];
    [data appendData:[self setFontSizeData:fontSize]];
    [data appendData:[self boldData:isBold]];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    if (_printSize == QYOrderPrintSize58mm) {
        NSInteger printContentCountFor58mm = 17;
        NSInteger count = 0;
        while (count * printContentCountFor58mm < string.length) {
            NSUInteger length = string.length - count * printContentCountFor58mm;
            if (length > printContentCountFor58mm) {
                length = printContentCountFor58mm;
            }
            NSString *printString = [string substringWithRange:NSMakeRange(count * printContentCountFor58mm, length)];
            [data appendData:[printString dataUsingEncoding:enc]];
            [data appendData:[self newLineData]];
            count++;
        }
    } else {
        [data appendData:[string dataUsingEncoding:enc]];
        [data appendData:[self newLineData]];
    }
    [self addDataToBuffer:data];
}

- (void)printFroTemplateWithStrings:(NSArray *)strings
                        atPositions:(NSArray *)positions
                      withAlighType:(NSArray *)alignTypes
                           fontSize:(QYPrinterFontSize)fontSize
                           fontType:(QYPrinterFontType)fontType
                             isBold:(BOOL)isBold {
    NSUInteger count = strings.count;
    if (count > positions.count || count > alignTypes.count) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self printerInitData]];
    [data appendData:[self setFontSizeData:fontSize]];
    [data appendData:[self setFontTypeData:fontType]];
    [data appendData:[self lineSpaceData:0x01]];
    if (isBold) {
        [data appendData:[self boldData:YES]];
    }
    // 字符所占的宽度
    NSInteger charWidth = 12;
    if (fontSize == QYPrinterFontSizeWidthTwice || fontSize == QYPrinterFontSizeBothTwice) {
        charWidth = 24;
    }
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSMutableArray *startPostions = [[NSMutableArray alloc] init];
    for (int i = 0;i < count;i++) {
        NSString *string = strings[i];
        NSInteger position = [positions[i] integerValue];
        QYPrinterAlignType alignType = [alignTypes[i] integerValue];
        NSInteger stringByteCount = [string lengthOfBytesUsingEncoding:enc];
        
        if (alignType == QYPrinterAlignRight) {
            // 右对齐其实就是用纸张的右边距减去字符所占长度作为打印位置的开始
            position = position - stringByteCount * charWidth;
        }
        else if (alignType == QYPrinterAlignCenter) {
            // 右对齐其实就是用纸张中间减去字符所占长度的一半作为打印位置的开始
            position = position - stringByteCount / 2 * charWidth;
        }
        // 纸张两边默认保留4mm间距
        if (position > 8 * (_printPageWidth - 8)) {
            position = 8 * (_printPageWidth - 8);
        }
        startPostions[i] = @(position);
    }
    for (int i = 0;i < count; i++) {
        NSString *string = strings[i];
        NSInteger startPostion = [startPostions[i] integerValue];
        NSInteger stringByteCount = [string lengthOfBytesUsingEncoding:enc];
        if (startPostion < 0) {
            startPostion = 0;
        }
        Byte l = startPostion % 256;
        Byte h = startPostion / 256;
        [data appendData:[self absolutePostionDataWithL:l h:h]];
        if (i < count - 1) {
            NSInteger nextStartPosition = [startPostions[i + 1] integerValue];
            if (startPostion + stringByteCount * charWidth > nextStartPosition) {
                string = [string stringByAppendingString:@"\n"];
            }
        } else {
            string = [string stringByAppendingString:@"\n"];
        }
        [data appendData:[string dataUsingEncoding:enc]];
        [self addDataToBuffer:data];
        data = [[NSMutableData alloc] init];
    }
}

- (void)printBarCode:(NSString *)string wihtHeight:(NSUInteger)height {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self printerInitData]];
    [data appendData:[self setAlignTypeData:QYPrinterAlignCenter]];
    
    Byte bytes_wn[] = {0x1D, 0x77, 0x02};  // 条码宽度
    [data appendData:[[NSData alloc] initWithBytes:bytes_wn length:3]];
    
    Byte bytes_hn[] = {0x1D, 0x68, height};  // 条码高度
    [data appendData:[[NSData alloc] initWithBytes:bytes_hn length:3]];
    
    Byte bytes_fn[] = {0x1D, 0x66, 0x00};  // 条码字体
    [data appendData:[[NSData alloc] initWithBytes:bytes_fn length:3]];
    
    Byte bytes_hhn[] = {0x1D, 0x48, 0x00};  // 可识读字符的打印位置
    [data appendData:[[NSData alloc] initWithBytes:bytes_hhn length:3]];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *stringData = [string dataUsingEncoding: enc];
    
//    Byte bytes_kmn[] = {0x1D, 0x6B, 0x45, stringData.length};  // 打印一维条码code39
//    Byte bytes_kmn[] = {0x1D, 0x6B, 0x48, stringData.length};  // 打印一维条码code93
    Byte bytes_kmn[] = {0x1D, 0x6B, 0x49, stringData.length};  // 打印一维条码code128
    [data appendData:[[NSData alloc] initWithBytes:bytes_kmn length:4]];
    [data appendData:stringData];
    [data appendData:[self newLineData]];
    [self addDataToBuffer:data];
}

- (void)printQRCode:(NSString *)string width:(NSInteger)width {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self printerInitData]];
    [data appendData:[self setAlignTypeData:QYPrinterAlignCenter]];
    
    Byte bytes_qrcode_type[] = {0x1D, 0x5A, 0x02};    //  二维码类型
    [data appendData:[[NSData alloc] initWithBytes:bytes_qrcode_type length:3]];
    
    Byte bytes_qrcode_width[] = {0x1D, 0x77, 0x06};    //  宽度
    [data appendData:[[NSData alloc] initWithBytes:bytes_qrcode_width length:3]];
    
    Byte bytes_kmn[] = {0x1B, 0x5A, 0x00, 0x02, 0x00, (string.length & 0xff), ((string.length & 0xff00) >> 8)};  // 打印二维条码
    [data appendData:[[NSData alloc] initWithBytes:bytes_kmn length:7]];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *stringData = [string dataUsingEncoding: enc];
    [data appendData:stringData];
    [self addDataToBuffer:data];
}

// Xprinter Q2008版本支持的二维码打印
- (void)printXprinterQRCode:(NSString *)string width:(NSInteger)width {
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self printerInitData]];
    [data appendData:[self setAlignTypeData:QYPrinterAlignCenter]];
    
    Byte bytes_qrcode_width[] = {0x1D, 0x28, 0x6B, 0x30, 0x67, 0x07};    //  宽度
    [data appendData:[[NSData alloc] initWithBytes:bytes_qrcode_width length:6]];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *stringData = [string dataUsingEncoding: enc];
    
    Byte bytes_aperation_data[] = {0x1d, 0x28, 0x6b, ((stringData.length + 3) & 0xff), (((stringData.length + 3) & 0xff00) >> 8), 0x31, 0x50, 0x30};
    [data appendData:[[NSData alloc] initWithBytes:bytes_aperation_data length:8]];
    
    [data appendData:stringData];
    
    Byte bytes_kmn[] = {0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x51, 0x30};  // 打印二维条码
    [data appendData:[[NSData alloc] initWithBytes:bytes_kmn length:8]];
    
    [self addDataToBuffer:data];
}

- (void)cutPage {
    NSMutableData *data = [[NSMutableData alloc] init];
    Byte cut_page[] = {0x1D, 0x56, 0x00};  // 0为全切，1为半切
    [data appendData:[[NSData alloc] initWithBytes:cut_page length:3]];
    [self addDataToBuffer:data];
}

- (void)printLineType:(NSString *)lineString {
    [self addDataToBuffer:[self printerInitData]];
    [self addDataToBuffer:[self lineSpaceData:0x00]];
    [self addDataToBuffer:[self setFontSizeData:QYPrinterFontSizeNormal]];
    [self addDataToBuffer:[self setFontTypeData:QYPrinterFontType24]];
    [self addDataToBuffer:[lineString dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    [self addDataToBuffer:[self newLineData]];
}

#pragma mark 表格标准版

- (void)printXprinterStandardTemplate {
    UIImage *dataImage = [self rotationImage:[self createStandardTemplateWithOrder:nil width:1000 * 4 height:400 * 4]];
    [self printDataImage:dataImage withAlighType:QYPrinterAlignCenter maxWidth:540];
}


// 旋转图片
- (UIImage *)rotationImage:(UIImage *)inImage {
    CGRect rect = CGRectMake(0, 0, inImage.size.height, inImage.size.width);
    float scaleY = rect.size.width/rect.size.height;
    float scaleX = rect.size.height/rect.size.width;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, 3 * M_PI_2);
    CGContextTranslateCTM(context, -rect.size.height, 0.0);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), inImage.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
}

- (UIImage *)createStandardTemplateWithOrder:(NSObject *)order width:(CGFloat)width height:(CGFloat)height {
    CGFloat mRate = 4.0;
    int margin = 2 * mRate;
    
    // 游标
    int xCursor = 0;
    int yCrusor = 0;
    // 表格高
    CGFloat tableFormHeight = 25.0 * mRate;
    CGFloat textHeight = 20.0 * mRate;
    
    NSDictionary *textArrtibutes = @{ NSFontAttributeName : [UIFont systemFontOfSize:16 * mRate]};
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    // 设置打印生成的位图背景色为白色
    CGRect rect = CGRectMake(0, 0, width, height);
    [[UIColor whiteColor] set];
    UIRectFill(rect);
    
    // 公司名
    NSString *companyName = @"车满满北京信息技术有限公司(发站存根联)";
    [companyName drawInRect:CGRectMake(48 * mRate, margin, 700 * mRate, 30 * mRate) withAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:28 * mRate]}];
    
    // 条形码
    [[MMQRCode barCodeWithString:@"12345" width:300 height:50] drawInRect:CGRectMake(650 * mRate, 0, 300 *mRate, 50 *mRate)];
    yCrusor = 47 * mRate;
    
    NSString *billingData = @"开单日期：2016-08-05";
    [billingData drawInRect:CGRectMake(margin, yCrusor, 200 * mRate, textHeight) withAttributes:textArrtibutes];
    xCursor = 200 * mRate + margin;
    
    NSString *sendStation = @"发站：北京";
    [sendStation drawInRect:CGRectMake(xCursor + 50 * mRate, yCrusor, 200 * mRate, textHeight) withAttributes:textArrtibutes];
    xCursor+= 200 * mRate + 50 *mRate;
    
    NSString *arriveStation = @"到站：武汉";
    [arriveStation drawInRect:CGRectMake(xCursor + 50 * mRate, yCrusor, 200 * mRate, textHeight) withAttributes:textArrtibutes];
    xCursor += 200 * mRate + 50 * mRate;
    
    NSString *orderNum = @"运单号：1111222333";
    [orderNum drawInRect:CGRectMake(xCursor + 40 * mRate, yCrusor, 200 * mRate, textHeight) withAttributes:textArrtibutes];
    yCrusor = 70 * mRate;
    
    // 获取上下文和配置
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0 * mRate);
    [[UIColor blackColor] set];
    
    // 画表格
    CGFloat formWidth = width - margin * 2;
    CGFloat formHeight = height - yCrusor - tableFormHeight;
    UIRectFrame(CGRectMake(margin, yCrusor, formWidth, formHeight));
    
    // 画横线
    CGFloat lineHeight = yCrusor;
    for (int i = 1; i <= 5; i ++) {
        if (i == 5) {
            lineHeight += tableFormHeight * 2;
        } else {
            lineHeight += tableFormHeight;
        }
        CGContextMoveToPoint(context, margin, lineHeight);
        CGContextAddLineToPoint(context, width - margin, lineHeight);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    // 画竖线
    CGFloat formWidth_inne = formWidth / 10.0;
    for (int i = 1; i <= 2; i++) {
        CGContextMoveToPoint(context, (formWidth_inne * 3) * i, yCrusor);
        CGContextAddLineToPoint(context, (formWidth_inne * 3) * i, yCrusor + tableFormHeight * 2);
        CGContextDrawPath(context, kCGPathStroke);
    }
    yCrusor += tableFormHeight * 2;
    
    for (int i = 1; i < 9; i++) {
        CGContextMoveToPoint(context, formWidth_inne * i, yCrusor);
        CGContextAddLineToPoint(context, formWidth_inne * i, yCrusor + tableFormHeight * 2);
        CGContextDrawPath(context, kCGPathStroke);
    }
    yCrusor += tableFormHeight * 2;
    
    CGContextMoveToPoint(context, formWidth_inne * 5, yCrusor);
    CGContextAddLineToPoint(context, formWidth_inne * 5, yCrusor + formHeight - tableFormHeight * 4);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextMoveToPoint(context, formWidth_inne * 8, yCrusor);
    CGContextAddLineToPoint(context, formWidth_inne * 8, yCrusor + formHeight - tableFormHeight * 4);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextMoveToPoint(context, formWidth_inne * 9, yCrusor);
    CGContextAddLineToPoint(context, formWidth_inne * 9, yCrusor + tableFormHeight * 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    //末尾
    CGFloat form_bottom = 70 * mRate + formHeight;
    NSString *creater = @"经办人：冯爷";
    [creater drawInRect:CGRectMake(margin * 2, form_bottom + margin, formWidth_inne * 3, textHeight) withAttributes:textArrtibutes];
    xCursor = formWidth_inne * 3 + margin * 2;
    
    NSString *sender = @"发货人签字：";
    [sender drawInRect:CGRectMake(xCursor + 50 * mRate, form_bottom + margin, formWidth_inne * 3, textHeight) withAttributes:textArrtibutes];
    xCursor += formWidth_inne * 3;
    
    NSString *receiver = @"收货人签字：";
    [receiver drawInRect:CGRectMake(xCursor + 50 * mRate, form_bottom + margin, formWidth_inne * 3, textHeight) withAttributes:textArrtibutes];
    
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
 
@end
