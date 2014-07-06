//
//  ConnectionLostViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionLostViewController.h"
#import "ConnectionProvider.h"
#import "UserDefaultManager.h"
#import "Encrypter.h"

@interface ConnectionLostViewController ()

@end

@implementation ConnectionLostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reconnect:(id)sender {
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *stream = [cp getConnection];
    if ([stream isConnected]) {
        [stream disconnect];
    }
    NSString *username = [UserDefaultManager loadUsername];
    NSString *password = [UserDefaultManager loadPassword];
    if (username != nil && password != nil) {
        [cp connect:username password:password];
    } else {
        // GO TO LOGIN SCREEN!
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
