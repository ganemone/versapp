//
//  MUCCreationManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPRoom.h"
#import "GroupChat.h"
#import "ChatMO.h"

@interface MUCCreationManager : NSObject <XMPPRoomDelegate>

+(ChatMO*)createMUC:(NSString*)roomName participants:(NSArray*)participants;

@end
