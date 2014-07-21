//
//  PhoneVerificationManager.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//


#import "PhoneVerificationManager.h"
#import "UserDefaultManager.h"
#import "Constants.h"
#import "AFNetworking.h"

NSString *const NSDEFAULT_KEY_VERIFICATION_CODE = @"nsdefault_key_verification_code";

@implementation PhoneVerificationManager

-(NSString *)loadVerificationCode {
    
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString *code = [preferences stringForKey:NSDEFAULT_KEY_VERIFICATION_CODE];
    return code;
}

-(void)saveVerificationCode:(NSString *)code {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:code forKey:NSDEFAULT_KEY_VERIFICATION_CODE];
    [preferences synchronize];
}

-(void)sendVerificationText {
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://versapp.co/verify/"];
        NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url];
        [uploadRequest setHTTPMethod:@"POST"];
        [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *phone = [UserDefaultManager loadPhone];
        NSString *country = [UserDefaultManager loadCountryCode];
        NSString *code = [self loadVerificationCode];
        if (code == nil || code.length == 0) {
            code = [NSString stringWithFormat:@"%d%d%d%d", arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9)];
            [self saveVerificationCode:code];
        }
        NSString *postString = [NSString stringWithFormat:@"phone=%@&country=%@&code=%@",phone, country, code];
        postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
        [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postString.length] forHTTPHeaderField:@"Content-Length"];
        [uploadRequest setHTTPBody:postData];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response statusCode] == 200) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SENT_VERIFICATION_TEXT object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
            }
        });
    });*/

    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *phone = [UserDefaultManager loadPhone];
    NSString *country = [UserDefaultManager loadCountryCode];
    NSString *code = [self loadVerificationCode];
    if (code == nil || code.length == 0) {
        code = [NSString stringWithFormat:@"%d%d%d%d", arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9)];
        [self saveVerificationCode:code];
    }
    NSLog(@"Verification Code: %@", code);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone" : phone,
                                 @"country" : country,
                                 @"code" : code};
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:VERIFY_URL parameters:parameters error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SENT_VERIFICATION_TEXT object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    }];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation start];
}

-(void)checkForPhoneRegisteredOnServer:(NSString *)countryCode phone:(NSString *)phone {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?ccode=%@&phone=%@", VALIDATE_URL, countryCode, phone]];
        NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url];
        [uploadRequest setHTTPMethod:@"GET"];
        [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        // create connection and set delegate if needed
        NSHTTPURLResponse *response = nil;
        NSError *error = NULL;
        [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Response Status Code: %d", [response statusCode]);
            if ([response statusCode] == 200) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONE_AVAILABLE object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONE_UNAVAILABLE object:nil];
            }
        });
    });
}

@end
