//
//  ChatParticipantVCardBuffer.h
//  Who
//
//  Created by Giancarlo Anemone on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

@interface ChatParticipantVCardBuffer : NSObject

+(id)getInstance;

-(void)addVCard:(NSDictionary*)vcard;

-(NSDictionary*)getVCard:(NSString*)username;

-(BOOL)hasVCard:(NSString*)username;

@end
