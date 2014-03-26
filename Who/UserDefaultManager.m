//
//  LoginManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/26/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserDefaultManager.h"
#import "Constants.h"

NSString *const NSDEFAULT_KEY_PASSWORD = @"nsdefault_key_password";
NSString *const NSDEFAULT_KEY_USERNAME = @"nsdefault_key_username";

@implementation UserDefaultManager

+(void)savePassword:(NSString *)password {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:password forKey:NSDEFAULT_KEY_PASSWORD];
    [preferences synchronize];
}

+(void)saveUsername:(NSString *)username {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:username forKey:NSDEFAULT_KEY_USERNAME];
    [preferences synchronize];
}

+(NSString *)loadPassword {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:NSDEFAULT_KEY_PASSWORD];
}

+(NSString *)loadUsername {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:NSDEFAULT_KEY_USERNAME];
}

+(void)clearUsernameAndPassword {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences removeObjectForKey:NSDEFAULT_KEY_USERNAME];
    [preferences removeObjectForKey:NSDEFAULT_KEY_PASSWORD];
    [preferences synchronize];
}

+(NSString *)loadName {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:VCARD_TAG_FULL_NAME];
}

+(NSString *)loadEmail {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:VCARD_TAG_EMAIL];
}

+(void)saveName:(NSString *)name {
    NSLog(@"Saving Name: %@", name);
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:name forKey:VCARD_TAG_FULL_NAME];
    [preferences synchronize];
}

+(void)saveEmail:(NSString *)email {
    NSLog(@"Saving Email: %@", email);
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:email forKey:VCARD_TAG_EMAIL];
    [preferences synchronize];
}


@end
