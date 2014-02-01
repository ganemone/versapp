//
//  OneToOneChat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneChat.h"
#import "ConnectionProvider.h"
#import "ChatParticipantVCardBuffer.h"
#import "Constants.h"

@implementation OneToOneChat

+(OneToOneChat *)create:(NSString *)threadID inviterID:(NSString *)inviterID invitedID:(NSString *)invitedID createdTimestamp:(NSString *)createdTimestamp {
    NSLog(@"Creating One To One: %@ %@", inviterID, invitedID);
    OneToOneChat *instance = [[OneToOneChat alloc] init];
    instance.chatID = threadID;
    instance.createdTime = createdTimestamp;
    if([invitedID compare:[ConnectionProvider getUser]] == 0) {
        instance.name = @"Anonymous Friend";
    } else {
        ChatParticipantVCardBuffer *buffer = [ChatParticipantVCardBuffer getInstance];
        NSDictionary *vcard = [buffer getVCard:invitedID];
        if (vcard != NULL) {
            instance.name = [vcard objectForKey:VCARD_TAG_NICKNAME];
        } else {
            instance.name = @"Loading...";
        }
    }
    instance.invitedID = invitedID;
    instance.inviterID = inviterID;
    instance.history = [History create:[[NSMutableArray alloc] init]];
    [instance.history addMessage:[Message createForOneToOne:@"This is a one to one message" sender:instance.invitedID chatID:instance.chatID messageTo:instance.inviterID]];
    [instance.history addMessage:[Message createForOneToOne:@"This is a much longer one to one message. The purpose of this message is to ensure that the text wrapps onto the next line and the height of the cell adjusts." sender:instance.invitedID chatID:instance.chatID messageTo:instance.inviterID]];
    [instance.history addMessage:[Message createForOneToOne:@"This is a one to one message" sender:instance.invitedID chatID:instance.chatID messageTo:instance.inviterID]];
    return instance;
}

-(NSString *)getMessageTo {
    return ([self.invitedID compare:[ConnectionProvider getUser]] == 0) ? self.inviterID : self.invitedID;
}

@end
