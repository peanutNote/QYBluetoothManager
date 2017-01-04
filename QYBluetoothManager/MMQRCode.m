//
//  MMQRCode.m
//  CMM
//
//  Created by qianye on 16/5/25.
//  Copyright © 2016年 zuozheng. All rights reserved.
//

#import "MMQRCode.h"

@implementation MMQRCode

+ (UIImage *)qrCodeWithString:(NSString *)string width:(CGFloat)width height:(CGFloat)height {
    if (string) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *stringData = [string dataUsingEncoding: enc];
        //创建二维码滤镜
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
        CIImage *qrImage = qrFilter.outputImage;
        //返回二维码
        UIImage *codeImage = [UIImage imageWithCIImage:[qrImage imageByApplyingTransform:CGAffineTransformMakeScale(width / CGRectGetWidth(qrImage.extent), height / CGRectGetHeight(qrImage.extent))]];
        
        return codeImage;
    }
    return nil;
}

+ (UIImage *)barCodeWithString:(NSString *)string width:(CGFloat)width height:(CGFloat)height {
    if (string) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *stringData = [string dataUsingEncoding: enc];
        //创建二维码滤镜
        CIFilter *barFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [barFilter setValue:stringData forKey:@"inputMessage"];
        CIImage *barImage = barFilter.outputImage;
        //返回二维码
        UIImage *codeImage = [UIImage imageWithCIImage:[barImage imageByApplyingTransform:CGAffineTransformMakeScale(width / CGRectGetWidth(barImage.extent), height / CGRectGetHeight(barImage.extent))]];
        
        return codeImage;
    }
    return nil;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf,
                                                 imageWidth,
                                                 imageHeight,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast
                                                 );
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth,
                                        imageHeight,
                                        8,
                                        32,
                                        bytesPerRow,
                                        colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little,
                                        dataProvider,
                                        NULL,
                                        true,
                                        kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
