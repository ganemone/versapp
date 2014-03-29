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
    NSLog(@"View did load for connection handling view controller");
    [super viewDidLoad];
    _shouldShowConnectionLostView = NO;
    _viewHasAppeared = NO;
    _connectionLostViewIsVisible = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectionLost) name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReconnect) name:NOTIFICATION_AUTHENTICATED object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewHasAppeared = YES;
    if (_shouldShowConnectionLostView) {
        [self handleConnectionLost];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    _shouldShowConnectionLostView = NO;
    _connectionLostViewIsVisible = NO;
}

- (void)showDisconnectedView {
    NSLog(@"Showing Disconnected View");
    ConnectionLostViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_CONNECTION_LOST_VIEW_CONTROLLER];
    [self presentViewController:vc animated:YES completion:nil];
    _connectionLostViewIsVisible = YES;
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
