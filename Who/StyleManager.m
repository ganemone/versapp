//
//  StyleManager.m
//  Who
//
//  Created by Giancarlo Anemone on 3/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "StyleManager.h"

@implementation StyleManager

static UIColor *colorOrange;
static UIColor *colorPurple;
static UIColor *colorGreen;
static UIColor *colorBlue;

+(UIFont*)getFontStyleLightSizeSmall {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:12];
    });
    return _font;
}

+(UIFont*)getFontStyleLightSizeMed {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:14];
    });
    return _font;
}

+(UIFont*)getFontStyleLightSizeLarge {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:16];
    });
    return _font;
}

+(UIFont*)getFontStyleLightSizeXL {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:18];
    });
    return _font;
}

+(UIFont *)getFontStyleLightSizeThought {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:22];
    });
    return _font;
}

+(UIFont *)getFontStyleLightSizeHeader {
    static dispatch_once_t onceToken;
    static UIFont *_font;
    dispatch_once(&onceToken, ^{
        _font = [UIFont fontWithName:@"MavenProLight300-Regular" size:30];
    });
    return _font;
}

+(UIFont*)getFontStyleLightSizeTitle {
    return [UIFont fontWithName:@"MavenProLight300-Regular" size:34];
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

+(UIFont*)getFontStyleBoldSizeTitle {
    return [UIFont fontWithName:@"MavenProBold" size:36];
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

+(CustomIOS7AlertView *)createCustomAlertView:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons hasInput:(BOOL)hasInput {
    CGFloat width = 0.8*[UIScreen mainScreen].bounds.size.width;
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    [content setFont:[StyleManager getFontStyleLightSizeLarge]];
    [content setTextAlignment:NSTextAlignmentCenter];
    [content setText:message];
    [content setBackgroundColor:[UIColor clearColor]];
    CGRect rect = [content.layoutManager usedRectForTextContainer:content.textContainer];
    [content setUserInteractionEnabled:NO];
    
    UIView *container;
    
    if (title != nil && ![title isEqualToString:@""]) {
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        [header setFont:[StyleManager getFontStyleBoldSizeLarge]];
        [header setTextAlignment:NSTextAlignmentCenter];
        [header setText:title];
        [header setBackgroundColor:[UIColor clearColor]];
        
        if (message != nil && ![message isEqualToString:@""])
            [content setFrame:CGRectMake(5, header.frame.size.height, width-10, rect.size.height+20)];
        else
            [content setFrame:CGRectMake(0, 0, 0, 0)];
        
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, header.frame.size.height+content.frame.size.height)];
        [container addSubview:header];
        [container addSubview:content];
    } else if (message != nil && ![message isEqualToString:@""]) {
        [content setFrame:CGRectMake(5, 0, width-10, rect.size.height+10)];
        
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, content.frame.size.height)];
        [container setContentMode:UIViewContentModeCenter];
        [container addSubview:content];
    }
    
    [container setBackgroundColor:[UIColor clearColor]];
    
    if (hasInput) {
        [alertView setHasInput:YES];
    }
    else {
        [alertView setHasInput:NO];
    }

    [alertView setButtonsOnly:NO];
    [alertView setContainerView:container];
    [alertView setButtonTitles:buttons];
    
    return alertView;
}

+(CustomIOS7AlertView *)createButtonOnlyAlertView:(NSArray *)buttons {
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    [alertView setButtonsOnly:YES];
    [alertView setButtonTitles:buttons];
    
    return alertView;
}

+(CustomIOS7AlertView *)createThoughtAlertView:(ThoughtMO *)thought thoughtView:(ThoughtTableViewCell *)thoughtView {
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    thoughtView = [[[NSBundle mainBundle] loadNibNamed:@"ThoughtTableViewCell" owner:self options:nil] firstObject];
    
    BOOL hasFavorited;
    if ([thought.hasFavorited isEqualToString:@"YES"]) {
        hasFavorited = YES;
    } else {
        hasFavorited = NO;
    }
    
    Confession *confession = [Confession create:thought.body posterJID:thought.posterJID imageURL:thought.imageURL confessionID:thought.confessionID createdTimestamp:thought.createdTimestamp degreeOfConnection:thought.degree hasFavorited:hasFavorited numFavorites:[thought.numFavorites intValue]];
    
    [thoughtView setUpWithConfession:confession];
    thoughtView.chatBtn.hidden = YES;
    thoughtView.degreeBtn.hidden = YES;
    thoughtView.favLabel.hidden = YES;
    thoughtView.favBtn.hidden = YES;
    
    [alertView setHasInput:NO];
    [alertView setButtonsOnly:NO];
    [alertView setContainerView:thoughtView];
    [alertView setButtonTitles:[NSArray arrayWithObject:@"Got it"]];
    
    return alertView;
}

@end
