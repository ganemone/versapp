//
//  ContactSearchViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactSearchViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface ContactSearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation ContactSearchViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendRequest:(id)sender {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSubscribePacket:_username.text]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Friend Request Sent" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (IBAction)handleBackPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end