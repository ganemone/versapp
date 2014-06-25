//
//  StyleManager.h
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomIOS7AlertView.h"

@interface StyleManager : NSObject

+(UIFont*)getFontStyleLightSizeSmall;
+(UIFont*)getFontStyleLightSizeMed;
+(UIFont*)getFontStyleLightSizeLarge;
+(UIFont*)getFontStyleLightSizeXL;
+(UIFont *)getFontStyleLightSizeThought;
+(UIFont*)getFontStyleLightSizeTitle;
+(UIFont *)getFontStyleLightSizeHeader;

+(UIFont*)getFontStyleRegularSizeSmall;
+(UIFont*)getFontStyleRegularSizeMed;
+(UIFont*)getFontStyleRegularSizeLarge;
+(UIFont*)getFontStyleRegularSizeXL;

+(UIFont*)getFontStyleMediumSizeSmall;
+(UIFont*)getFontStyleMediumSizeMed;
+(UIFont*)getFontStyleMediumSizeLarge;
+(UIFont*)getFontStyleMediumSizeXL;

+(UIFont*)getFontStyleBoldSizeSmall;
+(UIFont*)getFontStyleBoldSizeMed;
+(UIFont*)getFontStyleBoldSizeLarge;
+(UIFont*)getFontStyleBoldSizeXL;
+(UIFont*)getFontStyleBoldSizeTitle;

+(UIColor*)getColorOrange;
+(UIColor*)getColorBlue;
+(UIColor*)getColorPurple;
+(UIColor*)getColorGreen;

+(UIColor *)getRandomOrangeColor;
+(UIColor *)getRandomPurpleColor;
+(UIColor *)getRandomGreenColor;
+(UIColor *)getRandomBlueColor;

+(CustomIOS7AlertView *)createCustomAlertView: (NSString *)title message:(NSString *)message buttons:(NSArray *)buttons hasInput:(BOOL)hasInput;
+(CustomIOS7AlertView *)createButtonOnlyAlertView: (NSArray *)buttons;

@end
