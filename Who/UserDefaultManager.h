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
+(void)saveName:(NSString *)name;
+(void)saveEmail:(NSString *)email;
+(void)saveValidated:(BOOL)valid;
+(NSString*)loadPassword;
+(NSString*)loadUsername;
+(NSString *)loadName;
+(NSString *)loadEmail;
+(NSString *)loadCountryCode;
+(BOOL)isValidated;

@end
