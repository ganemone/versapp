//
//  BlacklistManager.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/7/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "BlacklistManager.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "IQPacketManager.h"

@implementation BlacklistManager

+ (void)sendPostRequestWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Setting up authorization header
    NSString *authCode = [NSString stringWithFormat:@"%@:%@", [ConnectionProvider getUser], delegate.sessionID];
    NSData *data = [authCode dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64AuthCode = [Base64 encode:data];
    NSString *authHttpHeaderValue = [NSString stringWithFormat:@"Basic %@", base64AuthCode];
    
    // Setting up post body
    NSString *postBody = [NSString stringWithFormat:@"%@,%@", [phoneNumbers componentsJoinedByString:@","], [emails componentsJoinedByString:@","]];
    NSString *postBodyWithoutSpace = [postBody stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Setting up request
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:BLACKLIST_URL parameters:nil error:&error];
    [req addValue:authHttpHeaderValue forHTTPHeaderField:BLACKLIST_AUTH_CODE];
    [req setHTTPBody:[postBodyWithoutSpace dataUsingEncoding:NSASCIIStringEncoding]];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Succeded With Operation: %@", operation);
        NSLog(@"Succeded With Response: %@", operation.responseString);
        ConnectionProvider *conn = [ConnectionProvider getInstance];
        [[conn getConnection] sendElement:[IQPacketManager createGetRosterPacket]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed Blacklist with error: %@", error);
    }];
    [operation setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [operation start];
}

@end
