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

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIView *registerView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) NSString *usernameText;
@property (strong, nonatomic) NSString *passwordText;
@property (strong, nonatomic) NSString *emailText;
@property (strong, nonatomic) NSString *firstNameText;
@property (strong, nonatomic) NSString *lastNameText;

@property BOOL createVCardWhenAuthenticated;
@property (strong, nonatomic) ConnectionProvider *cp;
@property (strong, nonatomic) LoadingDialogManager *ld;

- (IBAction)loginClick:(id)sender;
- (IBAction)register:(id)sender;
- (IBAction)signUpClick:(id)sender;
- (IBAction)cancelClick:(id)sender;

@end


@implementation LoginViewController

- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticated) name:@"authenticated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdVCard:) name:PACKET_ID_CREATE_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredUser:) name:PACKET_ID_REGISTER_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamDidDisconnect:) name:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotAuthenticate:) name:@"didNotAuthenticate" object:nil];
    
    self.createVCardWhenAuthenticated = NO;
    self.cp = [ConnectionProvider getInstance];
    self.ld = [LoadingDialogManager create:self.view];
    [self.username setDelegate:self];
    [self.password setDelegate:self];
    
    self.usernameText = [UserDefaultManager loadUsername];
    self.passwordText = [UserDefaultManager loadPassword];
    [self.username setText:_usernameText];
    [self.password setText:_passwordText];
    
    NSLog(@"Trying to login with: %@ %@", self.usernameText, self.passwordText);
    
    if (self.usernameText != nil && self.passwordText != nil) {
        [self login];
    }
}

-(void)authenticated
{
    NSLog(@"Reached Authenticated Selector in LoginViewController");
    if(self.createVCardWhenAuthenticated == YES) {
        NSLog(@"Sending Create ; Packet");
        [[self.cp getConnection] sendElement:[IQPacketManager createCreateVCardPacket:self.firstNameText lastname:self.lastNameText phone:self.usernameText email:self.emailText]];
    } else {
        [self.ld hideLoadingDialogWithoutProgress];
        [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
    }
}

- (IBAction)loginClick:(id)sender {
    self.passwordText = self.password.text;
    self.usernameText = self.username.text;
    
    [UserDefaultManager savePassword:self.passwordText];
    [UserDefaultManager saveUsername:self.usernameText];
    
    [self login];
}

- (void)login {
    [self.ld showLoadingDialogWithoutProgress];
    [self.cp connect:self.username.text password:self.password.text];
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
    [_ld hideLoadingDialogWithoutProgress];
    self.passwordText = @"";
}

- (IBAction)register:(id)sender{
    
    NSString *firstName, *lastName,
    //*username = @"1234512345",
    *username = self.username.text,
    *name = self.name.text,
    *password = self.password.text,
    *confirm = self.confirmPassword.text,
    *email = self.email.text;
    
    BOOL valid = YES;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z\\s\\'-]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
    if(matches.count > 0) {
        NSLog(@"Fails Name Validation");
        valid = NO;
    } else {
        NSArray *names = [name componentsSeparatedByString:@" "];
        if(names.count < 2) {
            NSLog(@"Fails Name Validation");
            valid = NO;
        } else {
            firstName = [names firstObject];
            lastName = [names lastObject];
            NSLog(@"Passes Name Validation");
        }
    }
    if(password.length > 6 && [password compare:confirm] == 0) {
        NSLog(@"Passes Password Validation");
    } else {
        NSLog(@"Fails Password Validation");
        valid = NO;
    }
    if(valid == YES) {
        self.usernameText = username;
        self.passwordText = password;
        self.firstNameText = firstName;
        self.lastNameText = lastName;
        self.emailText = email;
        NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:username, VCARD_TAG_USERNAME, password, USER_DEFAULTS_PASSWORD, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, email, VCARD_TAG_EMAIL, nil];
        [self.cp createAccount:accountInfo];
    } else {
        NSLog(@"Failed Validation");
    }
}

- (IBAction)signUpClick:(id)sender {
    self.registerButton.hidden = false;
    self.loginButton.hidden = true;
    self.signUpButton.hidden = true;
    self.cancelButton.hidden = false;
    self.registerView.hidden = false;
    self.email.hidden = false;
    self.confirmPassword.hidden = false;
    self.name.hidden = false;
}

- (IBAction)cancelClick:(id)sender {
    self.registerView.hidden = true;
    self.loginButton.hidden = false;
    self.signUpButton.hidden = false;
    self.registerButton.hidden = true;
}
@end
