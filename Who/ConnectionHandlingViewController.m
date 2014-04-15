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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReconnect) name:NOTIFICATION_AUTHENTICATED object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewHasAppeared = YES;
    if (_shouldShowConnectionLostView) {
        [self handleConnectionLost];
    } else {
        [_reconnectView removeFromSuperview];
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
        [_reconnectView removeFromSuperview];
        _shouldShowConnectionLostView = NO;
        _connectionLostViewIsVisible = NO;
    }
}

- (void)showDisconnectedView {
    XMPPStream *stream = [[ConnectionProvider getInstance] getConnection];
    if (![stream isConnecting] && ![stream isConnected] && ![stream isAuthenticated] && ![stream isAuthenticating]) {
        if (!_connectionLostViewIsVisible) {
            /*ConnectionLostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_CONNECTION_LOST_VIEW_CONTROLLER];
            [self presentViewController:vc animated:YES completion:nil];*/
            UIView *connectionView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 50)];
            UILabel *reconnectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, connectionView.frame.size.width, 50)];
            [reconnectLabel setText:@"Trying to Reconnect..."];
            [reconnectLabel setTextAlignment:NSTextAlignmentCenter];
            [reconnectLabel setTextColor:[UIColor whiteColor]];
            [connectionView setBackgroundColor:[UIColor blackColor]];
            [reconnectLabel setBackgroundColor:[UIColor clearColor]];
            [connectionView addSubview:reconnectLabel];
            _reconnectView = connectionView;
            [self.view addSubview:_reconnectView];
            _connectionLostViewIsVisible = YES;
        }
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
