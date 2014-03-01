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
    [label setFont:[UIFont fontWithName:@"MavenProLight300-Regular" size:20]];
}

+(void)setFontStyleNormalForLabel:(UILabel *)label {
    [label setFont:[UIFont fontWithName:@"MavenProLight200-Regular" size:16]];
}

+(void)setFontStyleNormalForTextView:(UITextView *)textview {
    [textview setFont:[UIFont fontWithName:@"MavenProLight200-Regular" size:16]];
 }

@end
