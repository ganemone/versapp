//
//  ChatParticipantVCardBuffer.m
//  Who
//
//  Created by Giancarlo Anemone on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChatParticipantVCardBuffer.h"
#import "Constants.h"

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
    [self.vcards setValue:vcard forKey:[vcard objectForKey:VCARD_TAG_USERNAME]];
}

-(NSDictionary*)getVCard:(NSString*)username {
    return [self.vcards objectForKey:username];
}



@end
