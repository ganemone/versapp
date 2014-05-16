//
//  ThoughtTableViewCell.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendsDBManager.h"
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
    
    
    if ([self heightForConfession] > 120) {
        [_body setFont:[StyleManager getFontStyleBoldSizeMed]];
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [self heightForConfessionWithFont:[StyleManager getFontStyleBoldSizeMed]] - 50) / 2.0f, 0, 0, 0)];
    } else {
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [self heightForConfession] - 40) / 2.0f, 0, 0, 0)];
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
            NSLog(@"Pre Image Size: %f %f", _backgroundImage.size.width, _backgroundImage.size.height);
            _backgroundImage = [self imageWithImage:_backgroundImage scaledToMaxWidth:320 maxHeight:320];
            NSLog(@"Post Image Size: %f %f", _backgroundImage.size.width, _backgroundImage.size.height);
            [imageView setImage:_backgroundImage];
            [self setBackgroundView:imageView];
        } else {
            [MBProgressHUD showHUDAddedTo:self.contentView animated:YES];
        }
    }
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
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
    if ([FriendsDBManager hasEnoughFriends]) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to start a chat with the poster of this thought?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Messaging is restricted to friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

-(void)handleConfessionDeleted:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to delete this thought?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [_confession deleteConfession];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [_confession startChat];
    }
}

- (CGFloat)heightForConfession {
    if (_height > 0.0f) {
        return _height;
    }
    UIFont *cellFont = [StyleManager getFontStyleBoldSizeXL];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [_body.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    _height = textRect.size.height;
    return _height;
    //_height = MAX(textRect.size.height + 80.0f, 121.0f);
    //return _height;
}

- (CGFloat)heightForConfessionWithFont:(UIFont *)cellFont {
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [_body.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    _height = textRect.size.height;
    return _height;
    //_height = MAX(textRect.size.height + 80.0f, 121.0f);
    //return _height;
}

@end
