//
//  LoginManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/26/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserDefaultManager.h"
#import "Constants.h"



@implementation UserDefaultManager

+(void)savePassword:(NSString *)password {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:password forKey:USER_DEFAULTS_PASSWORD];
    [preferences synchronize];
}

+(void)saveUsername:(NSString *)username {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:username forKey:USER_DEFAULTS_USERNAME];
    [preferences synchronize];
}

+(void)savePhone:(NSString *)phone {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:phone forKey:USER_DEFAULTS_PHONE];
    [preferences synchronize];
}

+(NSString *)loadPhone {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_PHONE];
}

+(NSString *)loadPassword {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_PASSWORD];
}

+(NSString *)loadUsername {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_USERNAME];
}

+(void)clearUsernameAndPassword {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences removeObjectForKey:USER_DEFAULTS_USERNAME];
    [preferences removeObjectForKey:USER_DEFAULTS_PASSWORD];
    [preferences synchronize];
}

+(NSString *)loadName {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:VCARD_TAG_FULL_NAME];
}

+(NSString *)loadEmail {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_EMAIL];
}

+(void)saveName:(NSString *)name {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:name forKey:VCARD_TAG_FULL_NAME];
    [preferences synchronize];
}

+(void)saveEmail:(NSString *)email {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:email forKey:USER_DEFAULTS_EMAIL];
    [preferences synchronize];
}

+(NSString *)loadCountryCode {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_COUNTRY_CODE];
}

+(void)saveCountryCode:(NSString *)code {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:code forKey:USER_DEFAULTS_COUNTRY_CODE];
    [preferences synchronize];
}

+(void)saveValidated:(BOOL)valid {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString *validString = [[NSString alloc] init];
    if (valid) {
        validString = @"valid";
    } else {
        validString = @"invalid";
    }
    [preferences setObject:validString forKey:USER_DEFAULTS_VALID];
    [preferences synchronize];
}

+(BOOL)isValidated {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([[preferences stringForKey:USER_DEFAULTS_VALID] compare:@"valid"] == 0) {
        return YES;
    } else {
        return NO;
    }
}

+(void)saveCountry:(NSString *)country {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:country forKey:USER_DEFAULTS_COUNTRY];
    [preferences synchronize];
}

+(NSString *)loadCountry {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_COUNTRY];
}

+(NSString *)loadDeviceID {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:USER_DEFAULTS_DEVICE_ID];
}

+(void)saveDeviceID:(NSString *)deviceID {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:deviceID forKey:USER_DEFAULTS_DEVICE_ID];
    [preferences synchronize];
}

+(BOOL)isUserDefaultValueTrue:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([[preferences stringForKey:key] isEqualToString:@"yes"]) {
        return YES;
    } else {
        return NO;
    }
}

+(void)setUserDefaultValueTrue:(NSString *)key {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:@"yes" forKey:key];
    [preferences synchronize];
}

+(BOOL)hasLoggedIn {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_FIRST_LOGIN];
}

+(BOOL)hasCreatedOneToOne {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_ONE_TO_ONE];
}

+(BOOL)hasCreatedGroup {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_GROUP];
}

+(BOOL)hasPostedThought {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_POSTED_THOUGHT];
}

+(BOOL)hasSeenThoughts {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_SEEN_THOUGHTS];
}

+(BOOL)hasStartedThoughtChat {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_THOUGHT_CHAT];
}

+(BOOL)hasReceivedOneToOneInvitation {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_RECEIVED_ONE_TO_ONE];
}

+(BOOL)hasSeenFriends {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_SEEN_FRIENDS];
}

+(void)setLoggedInTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_FIRST_LOGIN];
}

+(void)setCreatedOneToOneTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_ONE_TO_ONE];
}

+(void)setCreatedGroupTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_GROUP];
}

+(void)setPostedThoughtTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_POSTED_THOUGHT];
}

+(void)setSeenThoughtsTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_SEEN_THOUGHTS];
}

+(void)setStartedThoughtChatTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_CREATED_THOUGHT_CHAT];
}

+(void)setReceivedOneToOneInvitationTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_RECEIVED_ONE_TO_ONE];
}

+(void)setSeenFriendsTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_SEEN_FRIENDS];
}

+(BOOL)hasSentBlacklist; {
    return [self isUserDefaultValueTrue:USER_DEFAULTS_HAS_SENT_BLACKLIST];
}

+(void)setSentBlacklistTrue {
    [self setUserDefaultValueTrue:USER_DEFAULTS_HAS_SENT_BLACKLIST];
}


@end
