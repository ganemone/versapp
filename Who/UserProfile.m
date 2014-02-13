//
//  UserProfile.m
//  Who
//
//  Created by Fayang Pan on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//  User Profile

#import "UserProfile.h"

@implementation UserProfile

@synthesize subscriptionStatus;
@synthesize jid;
@synthesize nickname;
@synthesize email;
@synthesize firstName;
@synthesize lastName;

+(UserProfile *) create:(NSString *)jid subscriptionStatus:(int)subscriptionStatus {
    UserProfile *instance = [[UserProfile alloc] init];
    instance.jid = jid;
    instance.subscriptionStatus = subscriptionStatus;
    return instance;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"\n\n User Profile \n\n Subscription Status: %d \n JID: %@ \n Nickname: %@ \n Email: %@ \n First Name: %@ \n Last Name: %@ \n", subscriptionStatus, jid, nickname, email, firstName, lastName];
}

@end
