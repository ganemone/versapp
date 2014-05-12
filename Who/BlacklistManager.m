//
//  BlacklistManager.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/7/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "BlacklistManager.h"
#import "Encrypter.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "IQPacketManager.h"

@implementation BlacklistManager

+ (void)sendPostRequestWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails {

    NSLog(@"About to send blacklist post");
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Setting up authorization header
    NSString *authCode = [NSString stringWithFormat:@"%@:%@", [ConnectionProvider getUser], appDelegate.sessionID];
    NSData *data = [authCode dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64AuthCode = [Base64 encode:data];
    NSString *authHttpHeaderValue = [NSString stringWithFormat:@"Basic %@", base64AuthCode];
    NSLog(@"Authorization Header: %@", authHttpHeaderValue);
    
    // Setting up post body
    NSString *postBody = [NSString stringWithFormat:@"%@,%@", [phoneNumbers componentsJoinedByString:@","], [emails componentsJoinedByString:@","]];
    NSString *postBodyWithoutSpace = [postBody stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"Post Body: %@", postBodyWithoutSpace);
    // Setting up request
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:BLACKLIST_URL parameters:nil error:&error];
    [req addValue:authHttpHeaderValue forHTTPHeaderField:BLACKLIST_AUTH_CODE];
    [req setHTTPBody:[postBodyWithoutSpace dataUsingEncoding:NSASCIIStringEncoding]];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Blacklist Succeeded with response object: %@", responseObject);
        ConnectionProvider *conn = [ConnectionProvider getInstance];
        [[conn getConnection] sendElement:[IQPacketManager createGetRosterPacket]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Blacklist Failed: %@", error);
    }];
    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [operation start];
}

+ (void)encryptAndSendPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails {
    
}

@end
