//
//  ComposeConfessionViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ComposeConfessionViewController.h"
#import "Confession.h"
#import "ConfessionsManager.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"

@interface ComposeConfessionViewController ()

@end

@implementation ComposeConfessionViewController

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
    [[self composeTextView] becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedPostingConfession) name:PACKET_ID_POST_CONFESSION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postConfession:(id)sender {
    NSString *confessionText = [_composeTextView text];
    if (confessionText.length > 0) {
        Confession *confession = [Confession create:confessionText imageURL:nil];
        [[ConfessionsManager getInstance] setPendingConfession:confession];
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createPostConfessionPacket:confession]];
    } else {
        NSLog(@"No text in confession text box");
    }
}

- (IBAction)onBackPressed:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void)handleFinishedPostingConfession {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

@end
