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
#import "StyleManager.h"
#import "MBProgressHUD.h"

@interface ComposeConfessionViewController ()

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;

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
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    [self.composeTextView becomeFirstResponder];
    [self.composeTextView setFont:[StyleManager getFontStyleMediumSizeLarge]];
    [self.composeTextView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedPostingConfession) name:PACKET_ID_POST_CONFESSION object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postConfession:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    NSString *confessionText = [_composeTextView text];
    if (confessionText.length > 0) {
        Confession *confession = [Confession create:confessionText imageURL:nil];
        [[ConfessionsManager getInstance] setPendingConfession:confession];
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createPostConfessionPacket:confession]];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You didn't write anything!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

- (IBAction)onBackPressed:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void)handleFinishedPostingConfession {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.view setUserInteractionEnabled:YES];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > 1000) ? NO : YES;
}

@end
