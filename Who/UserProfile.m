//
//  UserProfile.m
//  Who
//
//  Created by Fayang Pan on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

+(UserProfile *) create:(NSString *)jid subscription_status:(NSString *)subscription_status{
    UserProfile *instance = [[UserProfile alloc] init];
    instance.jid = jid;
    instance.subscription_status = subscription_status;
    return instance;
}

@end
