//
//  ThoughtTableViewCell.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtTableViewCell.h"
#import "StyleManager.h"
#import "ConnectionProvider.h"
#import "Confession.h"
#import "IQPacketManager.h"
#import "ConfessionsManager.h"
#import "ImageManager.h"
#import "ImageCache.h"

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
    [self setUpBackgroundView];
}

- (void)setUp {
    [_body setText:[_confession body]];
    [_timestampLabel setText:[_confession getTimePosted]];
    [_favLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[_confession getNumForLabel]]];
    
    [_body setFont:[StyleManager getFontStyleBoldSizeXL]];
    [_body setTextColor:[UIColor whiteColor]];
    [_timestampLabel setTextColor:[UIColor whiteColor]];
    [_timestampLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
    [_favLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
    [_favLabel setTextColor:[UIColor whiteColor]];
    
    [_body setBackgroundColor:[UIColor clearColor]];
    [_timestampLabel setBackgroundColor:[UIColor clearColor]];
    [_favLabel setBackgroundColor:[UIColor clearColor]];
    
    [_body setUserInteractionEnabled:NO];
    [_timestampLabel setUserInteractionEnabled:NO];
    [_favLabel setUserInteractionEnabled:NO];
    [_body setTextAlignment:NSTextAlignmentCenter];
    [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [_confession heightForConfession] - 5) / 2.0f, 0, 0, 0)];
    if ([_confession heightForConfession] > 120) {
        [_body setFont:[StyleManager getFontStyleBoldSizeMed]];
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [_confession heightForConfessionWithFont:[StyleManager getFontStyleBoldSizeMed]] - 5) / 2.0f, 0, 0, 0)];
    }
    
    [_favBtn addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([_confession isFavoritedByConnectedUser]) {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon-active.png"] forState:UIControlStateNormal];
    } else {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
    }
    
    if ([_confession isPostedByConnectedUser]) {
        [_chatBtn addTarget:self action:@selector(handleConfessionDeleted:) forControlEvents:UIControlEventTouchUpInside];
        [_chatBtn setTitle:@"Remove" forState:UIControlStateNormal];
    } else {
        [_chatBtn setTitle:@"Chat" forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setUpBackgroundView {
    if ([[_confession.imageURL substringToIndex:1] isEqualToString:@"#"]) {
        [self setBackgroundColor:[StyleManager getRandomBlueColor]];
    } else if(!([_confession.imageURL isEqualToString:@""] || _confession.imageURL == nil)) {
        ImageCache *cache = [ImageCache getInstance];
        if ([cache hasImageWithIdentifier:_confession.confessionID]) {
            _backgroundImage = [cache getImageWithIdentifier:_confession.confessionID];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:_backgroundImage];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [self setBackgroundView:imageView];
        }
    }
}

-(void)handleConfessionFavorited:(id)sender {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createToggleFavoriteConfessionPacket:[_confession confessionID]]];
    
    BOOL isFavorited = [_confession toggleFavorite];
    if (isFavorited) {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon-active.png"] forState:UIControlStateNormal];
    } else {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
    }
    [_favLabel setText:[_confession getTextForLabel]];
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    [confessionsManager updateConfession:_confession];
}

-(void)handleConfessionChatStarted:(id)sender {
    [_confession startChat];
}

-(void)handleConfessionDeleted:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to delete this thought?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [_confession deleteConfession];
    }
}

@end
