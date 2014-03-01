//
//  StyleManager.h
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StyleManager : NSObject

+ (void)setFontStyleHeaderForLabel:(UILabel*)label;

+ (void)setFontStyleNormalForLabel:(UILabel*)label;

+ (void)setFontStyleNormalForTextView:(UITextView*)textview;

+ (void)setFontStyleSmallForTextView:(UITextView*)textview;

+ (void)setFontStyleSmallForLabel:(UILabel*)label;

+(UIFont*)getFontStyleNormal;

+(UIFont*)getFontStyleLarge;

+(UIFont*)getFontStyleSmall;

@end
