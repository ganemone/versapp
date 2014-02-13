//
//  UserProfile.h
//  Who
//
//  Created by Fayang Pan on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//  User Profile

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property int subscriptionStatus;

+(UserProfile *) create:(NSString *)jid subscriptionStatus:(int)subscriptionStatus;

@end
