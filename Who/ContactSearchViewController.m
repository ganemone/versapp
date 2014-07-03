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
#import "FriendsDBManager.h"
#import "Constants.h"
#import "StyleManager.h"

@interface ContactSearchViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UILabel *description;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

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
    
    [_headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    [_description setFont:[StyleManager getFontStyleLightSizeLarge]];
    [_description setTextColor:[StyleManager getColorPurple]];
    [_username setFont:[StyleManager getFontStyleLightSizeLarge]];
    [_addButton.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [_addButton.layer setCornerRadius:5.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendRequest:(id)sender {
    NSString *usernameText = [[_username.text stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
    if ([FriendsDBManager hasUserWithJID:usernameText]) {
        NSString *message = [NSString stringWithFormat:@"%@ is already your friend!", _username.text];
        [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [_username setText:@""];
    } else {
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSubscribePacket:_username.text]];
        [FriendsDBManager insert:usernameText name:nil email:nil status:[NSNumber numberWithInt:STATUS_SEARCHED] searchedPhoneNumber:nil searchedEmail:nil uid:nil];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Friend Request Sent" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

- (IBAction)handleBackPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
