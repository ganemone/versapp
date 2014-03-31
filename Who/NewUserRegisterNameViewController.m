//
//  NewUserRegisterNameViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/30/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserRegisterNameViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "Validator.h"

@interface NewUserRegisterNameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation NewUserRegisterNameViewController

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
    [_headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    [_name setDelegate:self];
    [_email setDelegate:self];
    [_password setDelegate:self];
    [_confirmPassword setDelegate:self];
    
    [_name setTag:1];
    [_email setTag:2];
    [_password setTag:3];
    [_confirmPassword setTag:4];
    
    [_actionBtn addTarget:self action:@selector(handleActionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleActionBtnClicked {
    UIAlertView *alertView;
    if (![Validator isValidName:_name.text]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidEmail:_email.text]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidPassword:_password.text]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your password must be at least 6 digits long" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if (![Validator isValidPasswordPair:_password.text confirmPassword:_confirmPassword.text]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your passwords do not match." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_REGISTERING_NAME object:nil];
    }
    if (alertView != nil) {
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [self handleActionBtnClicked];
    }
    return NO; // We do not want UITextField to insert line-breaks.
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
