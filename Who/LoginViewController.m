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
#import "PhoneVerificationManager.h";
#import "ChatDBManager.h"

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

@property BOOL createVCardWhenAuthenticated;
@property (strong, nonatomic) ConnectionProvider *cp;
@property (strong, nonatomic) LoadingDialogManager *ld;

- (IBAction)loginClick:(id)sender;

@end

@implementation LoginViewController

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
    self.password.secureTextEntry = YES;
    
    self.usernameText = [UserDefaultManager loadUsername];
    self.passwordText = [UserDefaultManager loadPassword];
    [self.username setText:_usernameText];
    [self.password setText:_passwordText];
    
    PhoneVerificationManager *pvm = [[PhoneVerificationManager alloc] init];
    [pvm sendVerificationText];
    
    NSLog(@"user: %@ pass: %@", self.username.text, self.password.text);
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    _countries = [NSArray arrayWithContentsOfFile:file];
    
    [self.countryPicker setDataSource:self];
    [self.countryPicker setDelegate:self];
    
    _countryCode = @"1";
    NSInteger row = 218;
    
    if ([UserDefaultManager loadCountryCode] != nil) {
        NSNumber  *storedCode = [NSNumber numberWithInteger:[[UserDefaultManager loadCountryCode] integerValue]];
        for (NSDictionary *dict in _countries) {
            if ([dict objectForKey:@"code"] == storedCode) {
                _countryCode = [dict objectForKey:@"code"];
                row = [_countries indexOfObject:dict];
                break;
            }
        }
    }
    
    [self.countryPicker selectRow:row inComponent:0 animated:NO];
}

-(void)authenticated
{
    [self.ld hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_AUTHENTICATED sender:self];
}

- (IBAction)loginClick:(id)sender {
    if ([UserDefaultManager isValidated]) {
        self.passwordText = self.password.text;
        self.usernameText = self.username.text;
        
        [UserDefaultManager savePassword:self.passwordText];
        [UserDefaultManager saveUsername:self.usernameText];
        
        [self login];
    } else {
        [self.message setText:NOT_VALIDATED];
        //Need to navigate somewhere?
    }
}

- (void)login {
    [self.ld showLoadingDialogWithoutProgress];
    if ([self.username.text rangeOfString:@"-"].location == NSNotFound) {
        NSString *userWithCountryCode = [NSString stringWithFormat:@"%@-%@", _countryCode, self.username.text];
        [self.cp connect:userWithCountryCode password:self.password.text];
    } else {
        [self.cp connect:self.username.text password:self.password.text];
    }
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

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_countries count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_countries objectAtIndex:row] objectForKey:@"country"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _countryCode = [[_countries objectAtIndex:row] objectForKey:@"code"];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
