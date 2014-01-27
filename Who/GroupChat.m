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
