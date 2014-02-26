//
//  LoginManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/26/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const NSDEFAULT_KEY_PASSWORD;
extern NSString *const NSDEFAULT_KEY_USERNAME;

@interface LoginManager : NSObject

+(void)savePassword:(NSString*)password;
+(void)saveUsername:(NSString*)username;
+(NSString*)loadPassword;
+(NSString*)loadUsername;

@end
