//
//  StyleManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "StyleManager.h"

@implementation StyleManager

+(void)setFontStyleHeaderForLabel:(UILabel *)label {
    [label setFont: [self getFontStyleLarge]];
}

+(void)setFontStyleNormalForLabel:(UILabel *)label {
    [label setFont:[self getFontStyleNormal]];
}

+(void)setFontStyleNormalForTextView:(UITextView *)textview {
    [textview setFont: [self getFontStyleNormal]];
}

+(void)setFontStyleSmallForLabel:(UILabel *)label {
    [label setFont:[self getFontStyleSmall]];
}

+(void)setFontStyleSmallForTextView:(UITextView *)textview {
    [textview setFont:[self getFontStyleSmall]];
}

+(UIFont*)getFontStyleNormal {
    return [UIFont fontWithName:@"MavenProLight200-Regular" size:16];
}

+(UIFont*)getFontStyleLarge {
    return [UIFont fontWithName:@"MavenProLight300-Regular" size:20];
}

+(UIFont*)getFontStyleSmall {
    return [UIFont fontWithName:@"MavenProLight200-Regular" size:12];
}

@end
