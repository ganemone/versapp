//
//  MainTabBarController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MainTabBarController.h"
#import "AppDelegate.h"

@implementation MainTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    
    // Fetching Records and saving it in "fetchedRecordsArray" object
    [appDelegate insertMessage:@"blah" image_link:@"image link" message_body:@"body" message_id:1 reciever_id:1 sender_id:1 time:@"time"];
    
}

@end
