//
//  PhoneVerificationManager.h
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneVerificationManager : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(NSString *)loadVerificationCode;
-(void)saveVerificationCode:(NSString *)code;
-(void)sendVerificationText;
-(void)checkForPhoneRegisteredOnServer:(NSString *)countryCode phone:(NSString *)phone;

@end
