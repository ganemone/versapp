//
//  Validator.h
//  Versapp
//
//  Created by Giancarlo Anemone on 3/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validator : NSObject

+ (BOOL)isValidPhoneNumber:(NSString *)phone;
+ (BOOL)isValidEmail:(NSString *)email;
+ (BOOL)isValidName:(NSString *)name;
+ (BOOL)isValidUsername:(NSString *)username;
+ (BOOL)isValidPassword:(NSString *)password;
+ (BOOL)isValidPasswordPair:(NSString *)password confirmPassword:(NSString *)confirmPassword;

@end
