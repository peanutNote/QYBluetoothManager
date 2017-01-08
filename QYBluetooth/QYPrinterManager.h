//
//  QYPrinterManager.h
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QYPrinterAlignType) {
    QYPrinterAlignLeft   = 0x00,
    QYPrinterAlignCenter = 0x01,
    QYPrinterAlignRight  = 0x02
};

typedef NS_ENUM(Byte, QYPrinterFontType) {
    QYPrinterFontType24 = 0x00,
    QYPrinterFontType16 = 0x01,
    QYPrinterFontType32 = 0x02,
};

typedef NS_ENUM(Byte, QYPrinterFontSize) {
    QYPrinterFontSizeNormal = 0x00,
    QYPrinterFontSizeHeightTwice = 0x01,
    QYPrinterFontSizeWidthTwice = 0x10,
    QYPrinterFontSizeBothTwice = 0x11,
};

typedef NS_ENUM(NSInteger, QYOrderPrintSize) {
    QYOrderPrintSize80mm    = 1,
    QYOrderPrintSize58mm    = 2,
};

@protocol QYPrinterManagerDelegate <NSObject>

- (void)printData:(NSData *)data;

@end

@interface QYPrinterManager : NSObject

@property (nonatomic, weak) id<QYPrinterManagerDelegate> delegate;
/**
 *  打印纸张的类型
 */
@property (nonatomic, assign) QYOrderPrintSize printSize;
/**
 *  打印纸张的宽度
 */
@property (nonatomic, assign) NSInteger printPageWidth;
/**
 *  每pt转换到纸张上的倍率   1pt=rateOfPtAndPage*1mm
 */
@property (nonatomic, assign) NSInteger rateOfPtAndPage;

- (void)addDataToBuffer:(NSData *)data;

- (void)printerManagerInitData;

- (void)printAllData;

#pragma mark 芝柯表格打印(指令集：ZICOX_CPCL)

/**
 *  初始化
 *
 *  @param width  打印区域宽
 *  @param height 打印区域高
 */
- (void)mPrintInitDataWidth:(int)width Height:(int)height;

/**
 *  打印文字
 *
 *  @param isVertical 是否垂直打印
 *  @param font       字体编号,一共有0 1 2 4 5 6 7  英文字体,55 16点阵中文字体,其他编号之外的字体为        中文24点阵字体
 *  @param size       字体的大小识别符
 *  @param x          x轴起始位置
 *  @param y          Y轴其实位置
 *  @param content    需要被打印出来的数据
 */
- (void)mPrintTextData:(BOOL)isVertical font:(int)font size:(int)size x:(int)x y:(int)y content:(NSString *)content;

/**
 *  打印线段
 *
 *  @param x0    左上角X坐标
 *  @param y0    左上角Y坐标
 *  @param x1    右下角X坐标
 *  @param y1    右下角Y坐标
 *  @param width 线段的线宽
 */
- (void)mPrintLineWithX0:(int)x0 y0:(int)y0 x1:(int)x1 y1:(int)y1 width:(int)width;

/**
 *  打印矩形框
 *
 *  @param x0    左上角X坐标
 *  @param y0    左上角Y坐标
 *  @param x1    右下角X坐标
 *  @param y1    右下角Y坐标
 *  @param width 形成矩形的线宽
 */
- (void)mPrintBoxWithX0:(int)x0 y0:(int)y0 x1:(int)x1 y1:(int)y1 width:(int)width;

/**
 *  设置对齐方式
 *
 *  @param align 0/left 1/center 2/right
 */
- (void)mPrintSetAlign:(int)align;

/**
 *  设置打印速度
 *
 *  @param level 0-5的数值,0是最慢的速度
 */
- (void)mPrintSetSpeed:(int)level;

/**
 *  打印走纸
 *
 *  @param isFirst 是否为打印之前走纸，否则为打印之后走纸
 *  @param length  走纸距离
 */
- (void)mPrintFeed:(BOOL)isFirst length:(int)length;

/**
 *  设置粗体指令
 *
 *  @param apply 0取消粗体模式>1 设置打印字体为粗体，同时设置粗体数值
 */
- (void)mPrintSetBold:(int)apply;

/**
 *  字体放大
 *
 *  @param width  宽度放大
 *  @param height 高度放大
 */
- (void)mPrintSetMAG:(int)width height:(int)height;

/**
 *  设置字符间距
 *
 *  @param space 字符与字符之间的间隔大小,n*0.125mm
 */
- (void)mPrintSetSpace:(int)space;

/**
 *  打印条形码
 *
 *  @param isVertical 是否垂直打印
 *  @param height     条码高度点数(8点/mm)
 *  @param x          条码开始的X轴坐标
 *  @param y          条码开始的Y轴坐标
 *  @param content    条码数据
 */
- (void)mPrintBarCode:(BOOL)isVertical height:(int)height x:(int)x y:(int)y content:(NSString *)content;

/**
 *  打印二维码
 *
 *  @param isVertical 是否垂直打印
 *  @param x          条码开始的X轴坐标
 *  @param y          条码开始的Y轴坐标
 *  @param content    QR条码数据,在数据中会包括一些模式选择
 */
- (void)mPrintQRCode:(BOOL)isVertical x:(int)x y:(int)y content:(NSString *)content;

/**
 *  指令控制结束并打印控制内容
 */
- (void)mPrintEnd;

#pragma mark - ESC/POS指令打印

#pragma mark 基础指令

/**
 *  打印机初始化，清除打印缓冲区中的数据,设置打印命令参数到缺省设置
 *
 *  @return 指令数据
 */
- (NSData *)printerInitData;

/**
 *  把打印缓冲区中的数据打印出来,并按当前设定的行间距向前走纸一行
 *
 *  @return 指令数据
 */
- (NSData *)newLineData;

/**
 *  下划线
 *
 *  @return 指令数据
 */
- (NSData *)underLineData:(Byte)type;

/**
 *  设定或解除粗体打印模式
 *
 *  @param enabled NO:解除粗体打印模式 YES:设定粗体打印模式
 *
 *  @return 指令数据
 */
- (NSData *)boldData:(BOOL)enabled;

/**
 *  设置字符行间距为 n 个垂直点距,每个垂直点距为0.125mm
 *
 *  @param lineSpace 0≤n≤127  n默认为8
 *
 *  @return 指令数据
 */
- (NSData *)lineSpaceData:(Byte)lineSpace;

/**
 *  设置字符右侧的间距为n个水平点距,每个水平点距为0.125mm。
 *
 *  @param rightMargin 0≤n≤48  n默认为0(0x80)
 *
 *  @return 指令数据
 */
- (NSData *)rightMarginData:(Byte)rightMargin;

/**
 *  设置字符左侧的间距为n个水平点距,每个水平点距为0.125mm。
 *
 *  @param leftMargin 0≤n≤48  n默认为0(0x80)
 *
 *  @return 指令数据
 */
- (NSData *)leftMarginData:(Byte)leftMargin;


/**
 *  设定从一行的开始到将要打印字符的位置之间的距离,从一行的开始到打印位置的距离为n个水平点距,每个水平点距为0.125mm。
 *
 *  @param l nL nH 是双字节无符号整数 n 的低位字节和高位字节,n=nL+nH*256
 *  @param h 同上
 *
 *  @return 指令数据
 */
- (NSData *)absolutePostionDataWithL:(Byte)l h:(Byte)h;


/**
 *  选择字符字体。
 *
 *  @param fontType 0x00 选择24点阵字库;0x01 选择16点阵字库;0x02 选择32点阵字库
 *
 *  @return 指令数据
 */
- (NSData *)setFontTypeData:(Byte)fontType;

/**
 *  用位0~3位选择字符高度,用位4~7位选择字符宽度(也就是0xHW，H高度，W表示宽)
 *
 *  @param fontSize 0≤n≤255
 *
 *  @return 指令数据
 */
- (NSData *)setFontSizeData:(Byte)fontSize;

/**
 *  将一行数据按照 n 指定的位置对齐
 *
 *  @param alignType 0x00 左对齐; 0x01 居中;0x02 右对齐
 *
 *  @return 指令数据
 */
- (NSData *)setAlignTypeData:(Byte)alignType;

/**
 *  切纸指令
 *
 *  @return 指令数据
 */
- (NSData *)cutPaperData;

#pragma mark 自定义打印指令

/**
 *  打印文本内容
 *
 *  @param string       文本内容
 *  @param alignType    对齐方式
 *  @param fontType     字体类型
 *  @param fontSize     字体大小
 *  @param isBold       是否加粗
 */
- (void)printString:(NSString *)string
          alignType:(QYPrinterAlignType)alignType
           fontType:(QYPrinterFontType)fontType
           fontSize:(QYPrinterFontSize)fontSize
             isBold:(BOOL)isBold;

/*
 * @abstract 模板单行多内容打印
 *
 * @param strings 要打印的内容数组.
 * @param positions 打印内容的位置表示为8*xx(mm),其中的xx为距纸张4mm(默认左边距可设置)处开始的位置
 * @param alignTypes  打印内容的排版对齐方式，如果是BTPrinterAlignTypeLeft表示以纸张左边4mm开始加上positions对应位置的数值，BTPrinterAlignTypeCenter为居中打印，BTPrinterAlignTypeRight为打印内容距纸张右边距离为positions对应位置的数值
 * @param fontSize 打印内容放大倍数.
 * @param fontType 打印字体大小
 * @param isBold 打印内容是否加粗.
 */
- (void)printFroTemplateWithStrings:(NSArray *)strings
                        atPositions:(NSArray *)positions
                      withAlighType:(NSArray *)alignTypes
                           fontSize:(QYPrinterFontSize)fontSize
                           fontType:(QYPrinterFontType)fontType
                             isBold:(BOOL)isBold;

/**
 *  打印条形码
 *
 *  @param string 条形码内容
 *  @param height 条形码高度 12≤n≤160 如果n<12, 条码高度将被设为 n=12 如果n>160,条码高度将被设为n=160 默认值n=36
 */
- (void)printBarCode:(NSString *)string wihtHeight:(NSUInteger)height;

- (void)printQRCode:(NSString *)string width:(NSInteger)width;

/**
 *  切纸指令
 */
- (void)cutPage;

/**
 *  打印线条类型
 *
 *  @param lineString 打印指令
 */
- (void)printLineType:(NSString *)lineString;

/**
 *  位图打印测试，有待完善
 */
- (void)printXprinterStandardTemplate;

- (void)printTest;

#pragma mark - 位图打印

- (void)printDataImage:(UIImage *)image withAlighType:(QYPrinterAlignType)alignType maxWidth:(CGFloat)maxWidth;

@end
