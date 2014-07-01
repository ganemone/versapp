//
//  Connection.m
//  The Arb
//
//  Created by Riley Lundquist on 6/26/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import "Connection.h"
#import "Constants.h"

@implementation Connection

+(NSData *)makeRequestFor:(NSString *)type {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8888/Arb/main.php?type=%@", SERVER_ADDRESS, type]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"GET"];
    
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"Response: %@, Error: %@", response, error);
    
    return data;
}

@end
