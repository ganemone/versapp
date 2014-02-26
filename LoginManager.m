//
//  LoginManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/26/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "LoginManager.h"

NSString *const NSDEFAULT_KEY_PASSWORD = @"nsdefault_key_password";
NSString *const NSDEFAULT_KEY_USERNAME = @"nsdefault_key_username";

@implementation LoginManager

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

@end
