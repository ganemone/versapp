//
//  ChatParticipantVCardBuffer.m
//  Who
//
//  Created by Giancarlo Anemone on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChatParticipantVCardBuffer.h"
#import "Constants.h"
#import "OneToOneChatManager.h"
#import "OneToOneChat.h"
#import "ConnectionProvider.h"

@interface ChatParticipantVCardBuffer()

@property (strong, nonatomic) NSMutableDictionary *vcards;

@end


static ChatParticipantVCardBuffer *selfInstance;

@implementation ChatParticipantVCardBuffer

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.vcards = [[NSMutableDictionary alloc] init];
        }
    }
    return selfInstance;
}

-(void)addVCard:(NSDictionary*)vcard {
    NSString *username = [vcard objectForKey:VCARD_TAG_USERNAME];
    [self.vcards setValue:vcard forKey:username];
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    OneToOneChat *chat;
    for (int i = 0; i < [cm getNumberOfChats]; i++) {
        chat = [cm getChatByIndex:i];
        NSLog(@"Invited ID: %@", chat.invitedID);
        NSLog(@"Inviter ID: %@", chat.inviterID);
        if([chat.invitedID compare:username] == 0 && [username compare:[ConnectionProvider getUser]] != 0) {
            chat.name = [vcard objectForKey:VCARD_TAG_NICKNAME];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
        }
    }
}

-(NSDictionary*)getVCard:(NSString*)username {
    return [self.vcards objectForKey:username];
}

-(BOOL)hasVCard:(NSString *)username {
    return !([self.vcards objectForKey:username] == NULL);
}



@end
