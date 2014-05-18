//
//  LoginManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/26/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultManager : NSObject

+(void)savePassword:(NSString*)password;
+(void)saveUsername:(NSString*)username;
+(void)clearUsernameAndPassword;
+(void)saveName:(NSString *)name;
+(void)saveEmail:(NSString *)email;
+(void)saveCountryCode:(NSString *)code;
+(void)saveValidated:(BOOL)valid;
+(void)saveCountry:(NSString *)country;
+(void)savePhone:(NSString *)phone;
+(void)saveDeviceID:(NSString *)deviceID;

+(NSString*)loadPassword;
+(NSString*)loadUsername;
+(NSString *)loadName;
+(NSString *)loadEmail;
+(NSString *)loadCountryCode;
+(NSString *)loadPhone;
+(NSString *)loadCountry;
+(NSString *)loadDeviceID;
+(NSString *)getThoughtDegree;

+(BOOL)isValidated;

+(BOOL)hasSentBlacklist;
+(BOOL)hasLoggedIn;
+(BOOL)hasCreatedOneToOne;
+(BOOL)hasCreatedGroup;
+(BOOL)hasPostedThought;
+(BOOL)hasSeenThoughts;
+(BOOL)hasStartedThoughtChat;
+(BOOL)hasReceivedOneToOneInvitation;
+(BOOL)hasSeenFriends;

+(void)setLoggedInTrue;
+(void)setCreatedOneToOneTrue;
+(void)setCreatedGroupTrue;
+(void)setPostedThoughtTrue;
+(void)setSeenThoughtsTrue;
+(void)setStartedThoughtChatTrue;
+(void)setReceivedOneToOneInvitationTrue;
+(void)setSeenFriendsTrue;
+(void)setSentBlacklistTrue;
+(void)setThoughtDegree:(NSString *)degree;

@end
