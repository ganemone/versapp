//
//  DashboardViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardViewController.h"
#import "AppDelegate.h"

@implementation DashboardViewController

-(void)viewDidLoad {
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    // Fetching Records and saving it in "fetchedRecordsArray" object
    [appDelegate insertMessage:@"blah" image_link:@"image link" message_body:@"body" message_id:1 reciever_id:1 sender_id:1 time:@"time"];
    NSArray *messages = [appDelegate getMessages];
    NSLog(@"Message Count: %d", messages.count);
    for (int i = 0; i < messages.count; i++) {
        NSLog(@"Messages: %@", [messages[i] description]);
    }
    
}

@end
