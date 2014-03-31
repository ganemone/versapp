//
//  Validator.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Validator.h"

@implementation Validator

+(BOOL)isValidEmail:(NSString *)email {
    return ([[email componentsSeparatedByString:@"@"] count] > 1);
}

+(BOOL)isValidName:(NSString *)name {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z\\'-]+\\s[a-zA-Z\\'-]+$" options:NSRegularExpressionCaseInsensitive error:&error];
    if ([regex matchesInString:name options:0 range:NSMakeRange(0, name.length)].count > 0) {
        return YES;
    }
    return NO;
}

+(BOOL)isValidPassword:(NSString *)password {
    return (password.length > 6);
}

+(BOOL)isValidPasswordPair:(NSString *)password confirmPassword:(NSString *)confirmPassword {
    return ([password isEqualToString:confirmPassword] && [Validator isValidPassword:password] && [Validator isValidPassword:confirmPassword]);
}

+(BOOL)isValidPhoneNumber:(NSString *)phone {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[0-9]+$" options:NSRegularExpressionCaseInsensitive error:&error];
    return ([[regex matchesInString:phone options:0 range:NSMakeRange(0, phone.length)] count] > 0);
}

+(BOOL)isValidUsername:(NSString *)username {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z_0-9]+$" options:NSRegularExpressionCaseInsensitive error:&error];
    return ([[regex matchesInString:username options:0 range:NSMakeRange(0, username.length)] count] > 0);
}


@end
