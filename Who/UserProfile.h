//
//  UserProfile.h
//  Who
//
//  Created by Fayang Pan on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//  User Profile

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (strong, nonatomic) NSString *subscription_status;
@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) NSString *name;

+(UserProfile *) create:(NSString *)jid subscription_status:(NSString *)subscription_status;

@end
