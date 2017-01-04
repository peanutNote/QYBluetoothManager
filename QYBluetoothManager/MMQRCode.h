//
//  MMQRCode.h
//  CMM
//
//  Created by qianye on 16/5/25.
//  Copyright © 2016年 zuozheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MMQRCode : NSObject

/**
 *  创建二维码
 *
 *  @param string 二维码
 *  @param width 二维码宽
 *  @param height 二维码高
 *
 *  @return 生成的二维码图片
 */
+ (UIImage *)qrCodeWithString:(NSString *)string width:(CGFloat)width height:(CGFloat)height;

/**
 *  创建条形码
 *
 *  @param string 条形码
 *  @param width 条形码宽
 *  @param height 条形码高
 *
 *  @return 生成的条形码图片
 */
+ (UIImage *)barCodeWithString:(NSString *)string width:(CGFloat)width height:(CGFloat)height;

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

@end
