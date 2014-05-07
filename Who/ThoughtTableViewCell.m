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
#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

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
    [_timestampLabel setFont:[StyleManager getFontStyleBoldSizeSmall]];
    [_favLabel setFont:[StyleManager getFontStyleBoldSizeSmall]];
    [_favLabel setTextColor:[UIColor whiteColor]];
    
    [_body setBackgroundColor:[UIColor clearColor]];
    [_timestampLabel setBackgroundColor:[UIColor clearColor]];
    [_favLabel setBackgroundColor:[UIColor clearColor]];
    
    [_body setUserInteractionEnabled:NO];
    [_timestampLabel setUserInteractionEnabled:NO];
    [_favLabel setUserInteractionEnabled:NO];
    [_body setTextAlignment:NSTextAlignmentCenter];
    
    if ([_confession heightForConfession] > 120) {
        [_body setFont:[StyleManager getFontStyleBoldSizeMed]];
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [_confession heightForConfessionWithFont:[StyleManager getFontStyleBoldSizeMed]] - 50) / 2.0f, 0, 0, 0)];
    } else {
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [_confession heightForConfession] - 40) / 2.0f, 0, 0, 0)];
    }
    
    [_favBtn addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([_confession isFavoritedByConnectedUser]) {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon-active.png"] forState:UIControlStateNormal];
    } else {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
    }
    
    if ([_confession isPostedByConnectedUser]) {
        [_chatBtn addTarget:self action:@selector(handleConfessionDeleted:) forControlEvents:UIControlEventTouchUpInside];
        [_chatBtn setImage:[UIImage imageNamed:@"x-white.png"] forState:UIControlStateNormal];
        //[_chatBtn setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    } else {
        [_chatBtn setImage:[UIImage imageNamed:@"messages-icon-white.png"] forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        //[_chatBtn setContentEdgeInsets:UIEdgeInsetsZero];
    }
}

- (void)setUpBackgroundView {
    if ([[_confession.imageURL substringToIndex:1] isEqualToString:@"#"]) {
        NSLog(@"Image Color: %@", _confession.imageURL);
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        [self setBackgroundColor:[UIColor colorWithHexString:_confession.imageURL]];
    } else if(!([_confession.imageURL isEqualToString:@""] || _confession.imageURL == nil)) {
        ImageCache *cache = [ImageCache getInstance];
        if ([cache hasImageWithIdentifier:_confession.confessionID]) {
            [MBProgressHUD hideHUDForView:self.contentView animated:YES];
            _backgroundImage = [cache getImageWithIdentifier:_confession.confessionID];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
            [imageView setContentMode:UIViewContentModeScaleToFill];
            [imageView setImage:_backgroundImage];
            [self setBackgroundView:imageView];
        } else {
            [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
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
