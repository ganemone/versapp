//
//  UIColor+Hex.h
//  Versapp
//
//  Created by Giancarlo Anemone on 5/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;
+ (NSString *)hexStringWithUIColor:(UIColor *)color;

@end
