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
#import "Encrypter.h"
#import "SocialSharingManager.h"

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (strong, nonatomic) NSString *usernameText;
@property (strong, nonatomic) NSString *passwordText;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotAuthenticate:) name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    
    self.createVCardWhenAuthenticated = NO;
    self.cp = [ConnectionProvider getInstance];
    [_username setTag:0];
    [_password setTag:1];
    [self.username setDelegate:self];
    [self.password setDelegate:self];
    self.password.secureTextEntry = YES;
    
    self.passwordText = [UserDefaultManager loadPassword];
    [self.username setText:_usernameText];
    
    
    // Set up fonts
    [_headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    [_username setFont:[StyleManager getFontStyleLightSizeLarge]];
    [_password setFont:[StyleManager getFontStyleLightSizeLarge]];
    [_loginButton.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [_registerBtn.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    [_loginButton.layer setCornerRadius:5.0];
    [_registerBtn.layer setCornerRadius:5.0];
}

-(void)authenticated
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
}

- (IBAction)loginClick:(id)sender {
    self.passwordText = self.password.text;
    self.usernameText = [self.username.text lowercaseString];
    [self login];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)login {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [UserDefaultManager savePassword:self.passwordText];
    _usernameText = [_usernameText lowercaseString];
    [UserDefaultManager saveUsername:self.usernameText];
    NSLog(@"Password: %@", _passwordText);
    [self.cp connect:self.usernameText password:_passwordText];
}

- (void)createdVCard:(NSNotification *)notification {
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
    //[UserDefaultManager clearUsernameAndPassword];
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
