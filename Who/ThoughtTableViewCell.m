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
#import "ThoughtsDBManager.h"

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
    
    [_body setFont:[StyleManager getFontStyleLightSizeThought]];
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
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [self heightForConfessionWithFont:[StyleManager getFontStyleBoldSizeMed]] - 30) / 2.0f, 0, 0, 0)];
    } else {
        [_body setTextContainerInset:UIEdgeInsetsMake((_body.frame.size.height - [self heightForConfession] - 20) / 2.0f, 0, 0, 0)];
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
        [_chatBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    } else {
        [_chatBtn setImage:[UIImage imageNamed:@"compose-white.png"] forState:UIControlStateNormal];
        [_chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        //[_chatBtn setContentEdgeInsets:UIEdgeInsetsZero];
    }
    
    [_degreeBtn setTitle:@"" forState:UIControlStateNormal];
    [_degreeBtn setImage:[_confession imageForDegree] forState:UIControlStateNormal];
    _degreeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_degreeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_degreeBtn addTarget:self action:@selector(handleDegreeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([_confession.degree isEqualToString:@"global"]) {
        _chatBtn.hidden = YES;
    }
}

- (void)handleDegreeBtnClicked {
    NSString *title;
    NSString *message;
    if ([_confession.degree isEqualToString:@"1"]) {
        title = @"Friend";
        message = @"This is a thought posted by a direct friend.";
    } else if ([_confession.degree isEqualToString:@"2"]) {
        title = @"Friend of Friend";
        message = @"This is a thought posted by a friend of a friend. In other words, a 2nd degree connection.";
    } else {
        title = @"Global";
        message = @"This is a global thought. It isn't necessarily posted by anyone in your friends list.";
    }
    
    //[[[UIAlertView alloc] initWithTitle:@"Thought" message:message delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil] show];
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:title message:message buttons:[NSMutableArray arrayWithObject:@"Got it"] hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)setUpBackgroundView {
    if ([[_confession.imageURL substringToIndex:1] isEqualToString:@"#"]) {
        NSLog(@"Image Color: %@", _confession.imageURL);
        [MBProgressHUD hideHUDForView:self.contentView animated:YES];
        UIColor *color = [UIColor colorWithHexString:_confession.imageURL];
        NSLog(@"Setting color to: %@", [color description]);
        [self setBackgroundColor:color];
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
            ImageManager *im = [[ImageManager alloc] init];
            [im downloadImageForThought:_confession delegate:self];
        }
    }
}

- (void)setUpBackgroundViewWithImage:(UIImage *)image {
    NSLog(@"Setting up background view with image: %@", [image description]);
    _backgroundImage = [self imageWithImage:image scaledToMaxWidth:320 maxHeight:320];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    imageView.alpha = 0;
    imageView.image = _backgroundImage;
    [self setBackgroundView:imageView];
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1];
    imageView.alpha = 1;
    [UIView commitAnimations];
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
        if ([ThoughtsDBManager hasThoughtWithID:_confession.confessionID]) {
            [ThoughtsDBManager setHasFavoritedYes:_confession.confessionID];
        }
    } else {
        [_favBtn setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
        if ([ThoughtsDBManager hasThoughtWithID:_confession.confessionID]) {
            [ThoughtsDBManager setHasFavoritedNo:_confession.confessionID];
        }
    }
    [_favLabel setText:[_confession getTextForLabel]];
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    [confessionsManager updateConfession:_confession];
}

-(void)handleConfessionChatStarted:(id)sender {
    /*if ([FriendsDBManager hasEnoughFriends] && _confession.degree.length < 3) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to start a chat with the poster of this thought?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Messaging is restricted to friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }*/
    
    NSString *message;
    NSMutableArray *buttonTitles = [[NSMutableArray alloc] init];
    if ([FriendsDBManager hasEnoughFriends] && _confession.degree.length < 3) {
        message = @"Would you like to start a chat with the poster of this thought?";
        [buttonTitles addObjectsFromArray:[NSMutableArray arrayWithObjects:@"No", @"Yes", nil]];
    } else {
        message = @"Messaging is restricted to friends and friends of friends.";
        [buttonTitles addObjectsFromArray:[NSMutableArray arrayWithObject:@"Ok"]];
    }
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Conversation" message:message buttons:buttonTitles hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

-(void)handleConfessionDeleted:(id)sender {
    //[[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to delete this thought?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Delete Thought" message:@"Are you sure you want to delete this thought?" buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Delete", nil] hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

/*-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [_confession deleteConfession];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [_confession startChat];
    }
}*/

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Got it"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"No"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ok"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        [alertView close];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [alertView close];
        [_confession startChat];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [alertView close];
        [_confession deleteConfession];
    }
}

- (CGFloat)heightForConfession {
    return [self heightForConfessionWithFont:[StyleManager getFontStyleLightSizeThought]];
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

#pragma ImageManagerDelegate

-(void)didFinishDownloadingImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    [MBProgressHUD hideAllHUDsForView:self.contentView animated:YES];
    [self setUpBackgroundViewWithImage:image];
}

-(void)didFailToDownloadImageWithIdentifier:(NSString *)identifier {
    NSLog(@"Failed to download image...");
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {}
-(void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url withError:(NSError *)error {
    NSLog(@"Failed to upload image...");
}

@end
