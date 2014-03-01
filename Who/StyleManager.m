//
//  StyleManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "StyleManager.h"

@implementation StyleManager

+(void)setAllFontStyles {
    [[UILabel appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0]];
    [[UITextView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0]];
}

@end
