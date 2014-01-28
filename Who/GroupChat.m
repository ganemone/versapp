//
//  GroupChat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GroupChat.h"
#import "ConnectionProvider.h"

@interface GroupChat()

@property (strong, nonatomic) NSArray *participants;

@end

@implementation GroupChat

+(GroupChat*)create:(NSString *)chatID participants:(NSArray*)participants groupName:(NSString *)groupName owner:(NSString *)owner createdTime:(NSString *)createdTime {
    GroupChat *instance = [[GroupChat alloc] init];
    instance.chatID = chatID;
    instance.participants = participants;
    instance.name = groupName;
    instance.owner = owner;
    instance.createdTime = createdTime;
    instance.history = [History create:[[NSMutableArray alloc] init]];
    [instance.history addMessage:[Message createForMUC:@"Test message" sender:[ConnectionProvider getUser] chatID:chatID timestamp:createdTime]];
    [instance.history addMessage:[Message createForMUC:@"This is a longer message. The purpose of this message is to ensure that the text wraps onto the next line. Wow! Would you look at that. It worked :)" sender:[ConnectionProvider getUser] chatID:chatID timestamp:createdTime]];
    return instance;
}

+(NSString *)createGroupID {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@%f", [ConnectionProvider getServerIPAddress], timeStamp];
}

-(int)getNumberOfMessages {
    return [self.history getNumberOfMessages];
}


@end
