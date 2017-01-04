//  
//  QYThermalSupport.h
//  CMM
//  
//  Created by qianye on 16/5/19.
//  Copyright © 2016年 qianye. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@interface QYThermalSupport : NSObject

+ (NSData *)imageToThermalData:(UIImage*)image;
@end
