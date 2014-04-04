//
//  LoginViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "LoginViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "LoadingDialogManager.h"
#import "UserDefaultManager.h"
#import "ChatDBManager.h"
#import "StyleManager.h"
#import "MBProgressHUD.h"

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) NSString *usernameText;
@property (strong, nonatomic) NSString *passwordText;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;

@property BOOL createVCardWhenAuthenticated;
@property (strong, nonatomic) ConnectionProvider *cp;

- (IBAction)loginClick:(id)sender;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticated) name:@"authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdVCard:) name:PACKET_ID_CREATE_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredUser:) name:PACKET_ID_REGISTER_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamDidDisconnect:) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotAuthenticate:) name:@"didNotAuthenticate" object:nil];
    
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    
    self.createVCardWhenAuthenticated = NO;
    self.cp = [ConnectionProvider getInstance];
    [_username setTag:0];
    [_password setTag:1];
    [self.username setDelegate:self];
    [self.password setDelegate:self];
    self.password.secureTextEntry = YES;
    
    self.passwordText = [UserDefaultManager loadPassword];
    [self.username setText:_usernameText];
    [self.password setText:_passwordText];
}

-(void)authenticated
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
}

- (IBAction)loginClick:(id)sender {
    if ([UserDefaultManager isValidated]) {
        self.passwordText = self.password.text;
        self.usernameText = self.username.text;
        [self login];
    } else {
        [self.message setText:NOT_VALIDATED];
    }
}

- (void)login {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [UserDefaultManager savePassword:self.passwordText];
    [UserDefaultManager saveUsername:self.usernameText];
    
    [self.cp connect:self.usernameText password:self.password.text];
}

- (void)createdVCard:(NSNotification *)notification {
    NSLog(@"createdVCard");
    [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
}

- (void)registeredUser:(NSNotification *)notification {
    [self.cp disconnect];
    self.createVCardWhenAuthenticated = YES;
}

- (void)streamDidDisconnect:(NSNotification *)notification {
    if(self.createVCardWhenAuthenticated == YES) {
        [self.cp connect:self.usernameText password:self.passwordText];
    }
}

- (void)didNotAuthenticate:(NSNotification *) notification{
    [UserDefaultManager clearUsernameAndPassword];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your username and password could not be authenticated." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.passwordText = @"";
}

-(BOOL)validatePasswordFieldChangeFromString:(NSString*)originalString toString:(NSString*)newString {
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self login];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

@end
