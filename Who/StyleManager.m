//
//  StyleManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "StyleManager.h"

@implementation StyleManager

static UIFont *lightSmall;
static UIFont *lightMed;
static UIFont *lightLarge;
static UIFont *lightXL;

static UIColor *colorOrange;
static UIColor *colorPurple;
static UIColor *colorGreen;
static UIColor *colorBlue;

+(UIFont*)getFontStyleLightSizeSmall {
    if (lightSmall == nil) {
        lightSmall = [UIFont fontWithName:@"MavenProLight300-Regular" size:12];
    }
    return lightSmall;
}

+(UIFont*)getFontStyleLightSizeMed {
    if (lightMed == nil) {
        lightMed = [UIFont fontWithName:@"MavenProLight300-Regular" size:14];
    }
    return lightMed;
}

+(UIFont*)getFontStyleLightSizeLarge {
    if (lightLarge == nil) {
        lightLarge = [UIFont fontWithName:@"MavenProLight300-Regular" size:16];
    }
    return lightLarge;
}

+(UIFont*)getFontStyleLightSizeXL {
    if (lightXL == nil) {
        lightXL = [UIFont fontWithName:@"MavenProLight300-Regular" size:18];
    }
    return lightXL;
}

+(UIFont*)getFontStyleRegularSizeSmall {
    return [UIFont fontWithName:@"MavenProMedium" size:12];
}

+(UIFont*)getFontStyleRegularSizeMed {
    return [UIFont fontWithName:@"MavenProMedium" size:14];
}

+(UIFont*)getFontStyleRegularSizeLarge {
    return [UIFont fontWithName:@"MavenProMedium" size:16];
}

+(UIFont*)getFontStyleRegularSizeXL {
    return [UIFont fontWithName:@"MavenProMedium" size:18];
}

+(UIFont*)getFontStyleMediumSizeSmall {
    return [UIFont fontWithName:@"MavenProRegular" size:12];
}

+(UIFont*)getFontStyleMediumSizeMed {
    return [UIFont fontWithName:@"MavenProRegular" size:14];
}

+(UIFont*)getFontStyleMediumSizeLarge {
    return [UIFont fontWithName:@"MavenProRegular" size:16];
}

+(UIFont*)getFontStyleMediumSizeXL {
    return [UIFont fontWithName:@"MavenProRegular" size:24];
}

+(UIFont*)getFontStyleBoldSizeSmall {
    return [UIFont fontWithName:@"MavenProBold" size:12];
}

+(UIFont*)getFontStyleBoldSizeMed {
    return [UIFont fontWithName:@"MavenProBold" size:14];
}

+(UIFont*)getFontStyleBoldSizeLarge {
    return [UIFont fontWithName:@"MavenProBold" size:16];
}

+(UIFont*)getFontStyleBoldSizeXL {
    return [UIFont fontWithName:@"MavenProBold" size:18];
}

+(UIColor*)getColorOrange {
    if (colorOrange == nil) {
        colorOrange = [UIColor colorWithRed:244.0f/255.0f green:146.0f/255.0f blue:0 alpha:1];
    }
    return colorOrange;
}

+(UIColor*)getColorBlue {
    if (colorBlue == nil) {
        colorBlue = [UIColor colorWithRed:56.0f/255.0f green:167.0f/255.0f blue:222.0f/255.0f alpha:1];
    }
    return colorBlue;
}

+(UIColor*)getColorPurple {
    if (colorPurple == nil) {
        colorPurple = [UIColor colorWithRed:98.0f/255.0f green:44.0f/255.0f blue:132.0f/255.0f alpha:1];
    }
    return colorPurple;
}

+(UIColor*)getColorGreen {
    if (colorGreen == nil) {
        colorGreen = [UIColor colorWithRed:141.0f/255.0f green:193.0f/255.0f blue:38.0f/255.0f alpha:1];
    }
    return colorGreen;
}

+(UIColor *)getRandomBlueColor {
    CGFloat rand = arc4random_uniform(5);
    if (rand < 1.0f) {
        return [self getColorBlue];
    } else if (rand < 2.0f) {
        return [UIColor colorWithRed:141.0f/255.0f green:217.0f/255.0f blue:255.0f/255.0f alpha:1];
    } else if (rand < 3.0f) {
        return [UIColor colorWithRed:64.0f/255.0f green:192.0f/255.0f blue:255.0f/255.0f alpha:1];
    } else if (rand < 4.0f) {
        return [UIColor colorWithRed:70.0f/255.0f green:109.0f/255.0f blue:127.0f alpha:1];
    } else {
        return [UIColor colorWithRed:51.0f/255.0f green:153.0f/255.0f blue:204.0f/255.0f alpha:1];
    }
}

+(UIColor *)getRandomGreenColor {
    CGFloat rand = arc4random_uniform(5);
    if (rand < 1.0f) {
        return [self getColorGreen];
    } else if (rand < 2.0f) {
        return [UIColor colorWithRed:212.0f/255.0f green:255.0f/255.0f blue:127.0f/255.0f alpha:1];
    } else if (rand < 3.0f) {
        return [UIColor colorWithRed:186.0f/255.0f green:255.0f/255.0f blue:50.0f/255.0f alpha:1];
    } else if (rand < 4.0f) {
        return [UIColor colorWithRed:106.0f/255.0f green:127.0f/255.0f blue:63.0f/255.0f alpha:1];
    } else {
        return [UIColor colorWithRed:149.0f/255.0f green:204.0f/255.0f blue:40.0f/255.0f alpha:1];
    }
}

+(UIColor *)getRandomPurpleColor {
    CGFloat rand = arc4random_uniform(5);
    if (rand < 1.0f) {
        return [self getColorPurple];
    } else if (rand < 2.0f) {
        return [UIColor colorWithRed:219.0f/255.0f green:161.0f/255.0f blue:255.0f/255.0f alpha:1];
    } else if (rand < 3.0f) {
        return [UIColor colorWithRed:189.0f/255.0f green:85.0f/255.0f blue:255.0f/255.0f alpha:1];
    } else if (rand < 4.0f) {
        return [UIColor colorWithRed:109.0f/255.0f green:81.0f/255.0f blue:127.0f/255.0f alpha:1];
    } else {
        return [UIColor colorWithRed:151.0f/255.0f green:68.0f/255.0f blue:204.0f/255.0f alpha:1];
    }
}

+(UIColor *)getRandomOrangeColor {
    CGFloat rand = arc4random_uniform(5);
    if (rand < 1.0f) {
        return [self getColorOrange];
    } else if (rand < 2.0f) {
        return [UIColor colorWithRed:255.0f/255.0f green:183.0f/255.0f blue:76.0f/255.0f alpha:1];
    } else if (rand < 3.0f) {
        return [UIColor colorWithRed:255.0f/255.0f green:153.0f/255.0f blue:0 alpha:1];
    } else if (rand < 4.0f) {
        return [UIColor colorWithRed:127.0f/255.0f green:92.0f/255.0f blue:38.0f/255.0f alpha:1];
    } else {
        return [UIColor colorWithRed:204.0f/255.0f green:122.0f/255.0f blue:0 alpha:1];
    }
}

@end
