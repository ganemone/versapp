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


@end
