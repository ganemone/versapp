//
//  StyleManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "StyleManager.h"

@implementation StyleManager

+(UIFont*)getFontStyleNormal {
    return [UIFont fontWithName:@"MavenProLight200-Regular" size:16];
}

+(UIFont*)getFontStyleLarge {
    return [UIFont fontWithName:@"MavenProLight300-Regular" size:20];
}

+(UIFont*)getFontStyleSmall {
    return [UIFont fontWithName:@"MavenProLight200-Regular" size:12];
}

+(UIFont *)getFontStyleThickNormal {
    return [UIFont fontWithName:@"MavenProLight300-Regular" size:18];
}

+(UIFont *)getFontStyleMediumSmall {
    return [UIFont fontWithName:@"MavenProLight200-Regular" size:14];
}

@end
