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
    
    [_favBtn addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([_confession isFavoritedByConnectedUser]) {
        [_favBtn setTintColor:[UIColor blackColor]];
    } else {
        [_favBtn setTintColor:[UIColor whiteColor]];
    }
    
    if ([_confession isPostedByConnectedUser]) {
        [_chatBtn addTarget:self action:@selector(handleConfessionDeleted:) forControlEvents:UIControlEventTouchUpInside];
        [_chatBtn setTitle:@"Remove" forState:UIControlStateNormal];
    } else {
        [_chatBtn setTitle:@"Chat" forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)handleConfessionFavorited:(id)sender {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createToggleFavoriteConfessionPacket:[_confession confessionID]]];
    
    BOOL isFavorited = [_confession toggleFavorite];
    if (isFavorited) {
        [_favBtn setTintColor:[UIColor blackColor]];
        if ([_confession getNumForLabel] == 1) {
            //[_favBtn setImage:[UIImage imageNamed:@"fav-icon-label-single-active.png"] forState:UIControlStateNormal];
        } else {
            //[_favBtn setImage:[UIImage imageNamed:@"fav-icon-label-active.png"] forState:UIControlStateNormal];
        }
    } else {
        [_favBtn setTintColor:[UIColor whiteColor]];
        if ([_confession getNumForLabel] == 1) {
            //[_favBtn setImage:[UIImage imageNamed:@"fav-icon-label-single.png"] forState:UIControlStateNormal];
        } else {
            //[_favBtn setImage:[UIImage imageNamed:@"fav-icon-label.png"] forState:UIControlStateNormal];
        }
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
