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
    [_timestampLabel setText:[_confession getTextForLabel]];
    [_favLabel setText:[NSString stringWithFormat:@"%d", [_confession getNumForLabel]]];
    
    [_body setFont:[StyleManager getFontStyleBoldSizeLarge]];
    [_timestampLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
}

@end
