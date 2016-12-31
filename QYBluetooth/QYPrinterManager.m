//
//  QYPrinterManager.m
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import "QYPrinterManager.h"

const CGFloat printPageDefaultWidth = 79;

//static const NSInteger MAX_PRINT_STR_LENGTH = 20;

@implementation QYPrinterManager {
    NSMutableData *_bufferData;
}

- (instancetype)init {
    if (self = [super init]) {
        _bufferData = [NSMutableData data];
    }
    return self;
}

- (void)printerManagerInitData {
    _bufferData = [NSMutableData data];
}

- (void)addDataToBuffer:(NSData *)data {
    [_bufferData appendData:data];
}

- (void)printAllData {
    if (_delegate && [_delegate respondsToSelector:@selector(printData:)]) {
        [_delegate printData:_bufferData];
        [self printerManagerInitData];
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

/*
- (void)printDataImage:(UIImage *)image withAlighType:(BTPrinterAlignType)alignType maxWidth:(CGFloat)maxWidth {
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
    [self printImageData:imageData];
}

- (void)printImageData:(NSData *)data {
    NSInteger count = 0;
    while (count * MAX_PRINT_STR_LENGTH_TEST < data.length)
    {
        NSUInteger length = data.length - count * MAX_PRINT_STR_LENGTH_TEST;
        if (length > MAX_PRINT_STR_LENGTH_TEST)
        {
            length = MAX_PRINT_STR_LENGTH_TEST;
        }
        NSData *data1 = [data subdataWithRange:NSMakeRange(count * MAX_PRINT_STR_LENGTH_TEST, length)];
//        [self printData:data1];
        count++;
    }
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

 */
 
@end
