//
//  QYPrinterManager.h
//  QYBluetoothManager
//
//  Created by qianye on 16/12/30.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QYPrinterAlignType) {
    QYPrinterAlignLeft,
    QYPrinterAlignCenter,
    QYPrinterAlignRight
};

@protocol QYPrinterManagerDelegate <NSObject>

- (void)printData:(NSData *)data;

@end

@interface QYPrinterManager : NSObject

@property (nonatomic, weak) id<QYPrinterManagerDelegate> delegate;

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
 *  @param apply 0取消粗体模式  >1 设置打印字体为粗体，同时设置粗体数值
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

#pragma mark 位图打印

//- (void)printDataImage:(UIImage *)image withAlighType:(QYPrinterAlignType)alignType maxWidth:(CGFloat)maxWidth;

@end
