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

@property BOOL viewDidShow;
@property BOOL shouldTransition;
@property (nonatomic, strong) NSString *transitionTo;

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
    self.viewDidShow = NO;
    self.shouldTransition = YES;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticated) name:@"authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToAuthenticate) name:@"didNotAuthenticate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoDefaultsStored) name:@"needToRegister" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewDidShow = YES;
    if (_shouldTransition) {
        [self performSegueWithIdentifier:_transitionTo sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleAuthenticated {
    _shouldTransition = YES;
    _transitionTo = SEGUE_ID_AUTHENTICATED_FROM_APP_INIT;
    if (_viewDidShow) {
        [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED_FROM_APP_INIT sender:self];
    }
}

- (void)handleFailedToAuthenticate {
    _shouldTransition = YES;
    _transitionTo = SEGUE_ID_GO_TO_LOGIN_PAGE;
    if (_viewDidShow) {
        [self performSegueWithIdentifier:SEGUE_ID_GO_TO_LOGIN_PAGE sender:self];
    }
}

- (void)handleNoDefaultsStored {
    _shouldTransition = YES;
    _transitionTo = SEGUE_ID_GO_TO_REGISTER_PAGE;
    if (_viewDidShow) {
        [self performSegueWithIdentifier:SEGUE_ID_GO_TO_REGISTER_PAGE sender:self];
    }
}

@end
