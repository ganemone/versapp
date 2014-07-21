//
//  DashboardTableViewCell.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardTableViewCell.h"
#import "ChatMO.h"
#import "ChatDBManager.h"
#import "StyleManager.h"
#import "Constants.h"
#import "FriendsDBManager.h"


@implementation DashboardTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setUpWithChatMO:(ChatMO *)chatMo {
    [_chatName setTextColor:[StyleManager getColorBlue]];
    [_lastMessage setTextColor:[UIColor blackColor]];
    [_lastMessage setHidden:NO];
    
    [_chatName setText:[chatMo getChatName]];
    [_lastMessage setText:[chatMo getLastMessage]];
    NSLog(@"Setting Values: %@ %@", [chatMo getChatName], [chatMo getLastMessage]);
    
    if ([ChatDBManager doesChatHaveNewMessage:chatMo.chat_id]) {
        [_chatName setFont:[StyleManager getFontStyleBoldSizeLarge]];
        [_lastMessage setFont:[StyleManager getFontStyleBoldSizeMed]];
    } else {
        [_chatName setFont:[StyleManager getFontStyleLightSizeLarge]];
        [_lastMessage setFont:[StyleManager getFontStyleLightSizeMed]];
    }
    
    if([chatMo.chat_type isEqualToString:CHAT_TYPE_GROUP]) {
        [_chatTypeImageView setImage:[UIImage imageNamed:@"group-blue.png"]];
    } else if([chatMo.chat_type isEqualToString:CHAT_TYPE_ONE_TO_ONE_INVITER]) {
        [_chatTypeImageView setImage:[UIImage imageNamed:@"friend-blue.png"]];
    } else if([chatMo.chat_type isEqualToString:CHAT_TYPE_ONE_TO_ONE_INVITED]) {
        [_chatTypeImageView setImage:[UIImage imageNamed:@"unknown-blue.png"]];
    } else if([chatMo.chat_type isEqualToString:CHAT_TYPE_ONE_TO_ONE_CONFESSION]) {
        if ([[chatMo degree] isEqualToString:@"1"]) {
            [_chatTypeImageView setImage:[UIImage imageNamed:@"friend-blue.png"]];
        } else {
            [_chatTypeImageView setImage:[UIImage imageNamed:@"second-degree-blue.png"]];
        }
    }
}



@end
