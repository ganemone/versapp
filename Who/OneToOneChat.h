//
//  OneToOneChat.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Chat.h"

@interface OneToOneChat : Chat

+(OneToOneChat *)create:(NSString*)threadID inviterID:(NSString*)inviterID invitedID:(NSString*)invitedID createdTimestamp:(NSString*)createdTimestamp;

@end
