//
//  PhoneVerificationManager.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "PhoneVerificationManager.h"

NSString *const NSDEFAULT_KEY_VERIFICATION_CODE = @"nsdefault_key_verification_code";

@implementation PhoneVerificationManager

+(NSString *)loadVerificationCode {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:NSDEFAULT_KEY_VERIFICATION_CODE];
}

+(void)saveVerificationCode:(NSString *)code {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:code forKey:NSDEFAULT_KEY_VERIFICATION_CODE];
    [preferences synchronize];
}

+(void)sendVerificationText {
    
}

@end
