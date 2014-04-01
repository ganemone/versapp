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

NSString *const NSDEFAULT_KEY_VERIFICATION_CODE = @"nsdefault_key_verification_code";

@implementation PhoneVerificationManager

-(NSString *)loadVerificationCode {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    return [preferences stringForKey:NSDEFAULT_KEY_VERIFICATION_CODE];
}

-(void)saveVerificationCode:(NSString *)code {
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:code forKey:NSDEFAULT_KEY_VERIFICATION_CODE];
    [preferences synchronize];
}

-(void)sendVerificationText {
    NSLog(@"Reached Send Verification Text");
    NSURL *url = [NSURL URLWithString:@"http://media.versapp.co/verify/"];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *phone = [UserDefaultManager loadUsername];
    NSString *country = [UserDefaultManager loadCountryCode];
    NSString *code = [NSString stringWithFormat:@"%d%d%d%d", arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9), arc4random_uniform(9)];
    [self saveVerificationCode:code];
    NSString *postString = [NSString stringWithFormat:@"phone=%@&country=%@&code=%@",phone, country, code];
    postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postString.length] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody:postData];
    
    // create connection and set delegate if needed
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self];
    [conn start];
}

-(void)checkForPhoneRegisteredOnServer:(NSString *)countryCode phone:(NSString *)phone {
    NSLog(@"Reached Send Verification Text");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ejabberd.versapp.co/validate.php?ccode=%@&phone=%@",countryCode, phone]];
        NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:url];
        [uploadRequest setHTTPMethod:@"GET"];
        [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        // create connection and set delegate if needed
        NSHTTPURLResponse *response = nil;
        NSError *error = NULL;
        [NSURLConnection sendSynchronousRequest:uploadRequest returningResponse:&response error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([response statusCode] == 200) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONE_AVAILABLE object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PHONE_UNAVAILABLE object:nil];
            }
        });
    });
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"Received Post Response!!: %@", result);
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"Did Send Body Data: %ld \n %ld \n %ld", (long)bytesWritten, (long)totalBytesWritten, (long)totalBytesExpectedToWrite);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Did finish Loading");
 }

 -(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
     NSLog(@"Did fail with error: %@", error);
 }
 
 -(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
     NSLog(@"Did Receive Response: %@", response);
 }

@end
