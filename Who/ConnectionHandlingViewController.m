//
//  ConnectionHandlingViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionHandlingViewController.h"
#import "ConnectionLostViewController.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "MBProgressHUD.h"
#import "UserDefaultManager.h"
#import "StyleManager.h"

@implementation ConnectionHandlingViewController

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
    _shouldShowConnectionLostView = NO;
    _viewHasAppeared = NO;
    _connectionLostViewIsVisible = NO;
    _connectionLostView = [self getConnectionLostView];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(handleApplicationCameInfoForeground) name:NOTIFICATION_DID_BECOME_ACTIVE object:nil];
    [defaultCenter addObserver:self selector:@selector(handleApplicationWentIntoBackground) name:NOTIFICATION_DID_ENTER_BACKGROUND object:nil];
}

-(void)handleApplicationWentIntoBackground {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [defaultCenter removeObserver:self name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    [defaultCenter removeObserver:self name:NOTIFICATION_AUTHENTICATED object:nil];
}

-(void)handleApplicationCameInfoForeground {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [defaultCenter addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    [defaultCenter addObserver:self selector:@selector(didReconnect) name:NOTIFICATION_AUTHENTICATED object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewHasAppeared = YES;
    if (_shouldShowConnectionLostView) {
        [self handleConnectionLost];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleConnectionLost {
    if (_viewHasAppeared) {
        [self showDisconnectedView];
    } else {
        _shouldShowConnectionLostView = YES;
    }
}

- (void)didReconnect {
    if (_connectionLostViewIsVisible) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_connectionLostView removeFromSuperview];
        _shouldShowConnectionLostView = NO;
        _connectionLostViewIsVisible = NO;
    }
}

- (void)showDisconnectedView {
    NSTimeInterval delayInSeconds = 3.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        XMPPStream *stream = [[ConnectionProvider getInstance] getConnection];
        if (![stream isConnecting] && ![stream isConnected] && ![stream isAuthenticated] && ![stream isAuthenticating]) {
            if (_connectionLostViewIsVisible == NO) {
                [self.view addSubview:_connectionLostView];
                _connectionLostViewIsVisible = YES;
            }
        }
    });
}

- (void)handleConnecting {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    _connectionLostViewIsVisible = NO;
}

- (UIView *)getConnectionLostView {
    UIFont *font = [StyleManager getFontStyleLightSizeLarge];
    UIView *lostConnectionView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 100)];
    [lostConnectionView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *lostConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, lostConnectionView.frame.size.width, 20)];
    [lostConnectionLabel setTextAlignment:NSTextAlignmentCenter];
    [lostConnectionLabel setText:@"Whoops! You have lost connection."];
    [lostConnectionLabel setFont:font];
    [lostConnectionView addSubview:lostConnectionLabel];
    

    UIButton *lostConnectionButton = [[UIButton alloc] init];
    [lostConnectionButton setTitle:@"Reconnect" forState:UIControlStateNormal];
    CGSize textSize = [[[lostConnectionButton titleLabel] text] sizeWithAttributes:@{NSFontAttributeName:font}];
    [[lostConnectionButton titleLabel] setFont:font];
    [lostConnectionButton setFrame:CGRectMake(lostConnectionView.frame.size.width/2 - textSize.width/2 - 10, 50, textSize.width + 20, textSize.height + 10)];
    [lostConnectionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lostConnectionButton addTarget:self action:@selector(handleReconnectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [lostConnectionButton setBackgroundColor:[StyleManager getColorBlue]];
    [lostConnectionButton.layer setCornerRadius:5.0];
    [lostConnectionView addSubview:lostConnectionButton];
    
    return lostConnectionView;
}

- (void)handleReconnectButtonPressed {
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *stream = [cp getConnection];
    NSString *password = [UserDefaultManager loadPassword];
    NSString *username = [UserDefaultManager loadUsername];
    if (![stream isConnecting] &&
        ![stream isConnected] &&
        ![stream isAuthenticated] &&
        ![stream isAuthenticating] &&
        username != nil &&
        ![username isEqualToString:@""] &&
        password != nil &&
        ![password isEqualToString:@""])
    {
        [cp connect:username password:password];
        MBProgressHUD *progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [progressHud setLabelText:@"Reconnecting"];
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
