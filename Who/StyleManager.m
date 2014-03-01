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
    [[UILabel appearance] setFont:[UIFont fontWithName:@"Arial Black" size:18.0]];
    [[UITextView appearance] setFont:[UIFont fontWithName:@"MavenProLight   " size:12.0]];
    
    NSArray *fontFamilies = [UIFont fontNamesForFamilyName:@"Maven Pro Light"];
    NSLog(@"Font Families: %@", [fontFamilies componentsJoinedByString:@"\n\n"]);
    NSLog(@"Font Family Size: %lu", (unsigned long)[fontFamilies count]);
}

@end
