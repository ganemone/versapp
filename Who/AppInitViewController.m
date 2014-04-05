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
#import "StyleManager.h"
#import "Encrypter.h"
#import "FriendsDBManager.h"

@interface AppInitViewController ()

@property BOOL viewDidShow;
@property BOOL shouldTransition;
@property (nonatomic, strong) NSString *transitionTo;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImage;

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
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIImage *image = [[UIImage alloc] init];
    if (screen.size.height < 500) {
        image = [UIImage imageNamed:@"loadingScreenSmall.png"];
    } else {
        image = [UIImage imageNamed:@"loadingScreenLarge.png"];
    }
    [self.loadingImage setImage:image];
    
    self.viewDidShow = NO;
    self.shouldTransition = NO;
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticated) name:@"authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToAuthenticate) name:@"didNotAuthenticate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoDefaultsStored) name:@"needToRegister" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToAuthenticate) name:NOTIFICATION_LOGOUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToAuthenticate) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    
    NSArray *test = [FriendsDBManager getAllWithStatusPending];
    NSLog(@"Pending Friends At Init: %d", (int)[test count]);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewDidShow = YES;
    if (_shouldTransition && ([self isKindOfClass:[[self presentedViewController] class]] || [self presentedViewController] == nil)) {
        [self performSegueWithIdentifier:_transitionTo sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleAuthenticated {
    _transitionTo = SEGUE_ID_AUTHENTICATED_FROM_APP_INIT;
    _shouldTransition = YES;
    if (_viewDidShow && ([self isKindOfClass:[[self presentedViewController] class]] || [self presentedViewController] == nil)) {
        [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED_FROM_APP_INIT sender:self];
    }
}

- (void)handleFailedToAuthenticate {
    _transitionTo = SEGUE_ID_GO_TO_LOGIN_PAGE;
    _shouldTransition = YES;
    if (_viewDidShow && ([self isKindOfClass:[[self presentedViewController] class]] || [self presentedViewController] == nil)) {
        [self performSegueWithIdentifier:SEGUE_ID_GO_TO_LOGIN_PAGE sender:self];
    }
}

- (void)handleNoDefaultsStored {
    _transitionTo = SEGUE_ID_GO_TO_REGISTER_PAGE;
    _shouldTransition = YES;
    if (_viewDidShow && [self isKindOfClass:[[self presentedViewController] class]]) {
        [self performSegueWithIdentifier:SEGUE_ID_GO_TO_REGISTER_PAGE sender:self];
    }
}

@end
