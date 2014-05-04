//
//  UIColor+Hex.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

+(NSString *)hexStringWithUIColor:(UIColor *)uiColor {
    CGColorRef color = [uiColor CGColor];
    
    int numComponents = CGColorGetNumberOfComponents(color);
    int red,green,blue, alpha;
    const CGFloat *components = CGColorGetComponents(color);
    if (numComponents == 4){
        red =  (int)(components[0] * 255.0) ;
        green = (int)(components[1] * 255.0);
        blue = (int)(components[2] * 255.0);
        alpha = (int)(components[3] * 255.0);
    }else{
        red  =  (int)(components[0] * 255.0) ;
        green  =  (int)(components[0] * 255.0) ;
        blue  =  (int)(components[0] * 255.0) ;
        alpha = (int)(components[1] * 255.0);
    }
    
    NSString *hexString  = [NSString stringWithFormat:@"#%02x%02x%02x%02x",
                            alpha,red,green,blue];
    return hexString;
}

@end
