//
//  AppInitViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 3/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "AppInitViewController.h"
#import "ConnectionProvider.h"
#import "UserDefaultManager.h"
#import "Constants.h"

@interface AppInitViewController ()

@end

@implementation AppInitViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticated) name:@"authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToAuthenticate) name:@"didNotAuthenticate" object:nil];
    NSString *username = [UserDefaultManager loadUsername];
    NSString *password = [UserDefaultManager loadPassword];
    if (username != nil && password != nil) {
        [[ConnectionProvider getInstance] connect:username password:password];
    } else {
        [self handleNoDefaultsStored];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleAuthenticated {
    [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
}

- (void)handleFailedToAuthenticate {
    [self performSegueWithIdentifier:SEGUE_ID_GO_TO_LOGIN_PAGE sender:self];
}

- (void)handleNoDefaultsStored {
    
}

@end
