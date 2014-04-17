//
//  ThoughtTableViewCell.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtTableViewCell.h"
#import "StyleManager.h"

@implementation ThoughtTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setUpWithConfession:(Confession *)confession {
    _confession = confession;
    [self setUp];
}

- (void)setUp {
    [_body setText:[_confession body]];
    [_timestampLabel setText:[_confession getTimePosted]];
    [_favLabel setText:[NSString stringWithFormat:@"%d", [_confession getNumForLabel]]];
    
    [_body setFont:[StyleManager getFontStyleBoldSizeXL]];
    [_body setTextColor:[UIColor whiteColor]];
    [_timestampLabel setTextColor:[UIColor whiteColor]];
    [_timestampLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
    [_favLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
    [_favLabel setTextColor:[UIColor whiteColor]];
    
    UIColor *color = [[UIColor alloc] initWithRed:arc4random_uniform(100)/101.0f green:arc4random_uniform(100)/101.0f blue:arc4random_uniform(100)/101.0f alpha:1];
    [self setBackgroundColor:color];
    
    [_body setBackgroundColor:[UIColor clearColor]];
    [_timestampLabel setBackgroundColor:[UIColor clearColor]];
    [_favLabel setBackgroundColor:[UIColor clearColor]];
    
    [_body setUserInteractionEnabled:NO];
    [_timestampLabel setUserInteractionEnabled:NO];
    [_favLabel setUserInteractionEnabled:NO];
    [_body setTextAlignment:NSTextAlignmentCenter];
    [_body setTextContainerInset:UIEdgeInsetsMake((190 - [_confession heightForConfession]) / 2.0f, 0, 0, 0)];
}

@end
