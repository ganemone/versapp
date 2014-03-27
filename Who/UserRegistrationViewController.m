//
//  UserRegistrationViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 3/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserRegistrationViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "UserDefaultManager.h"
#import "LoginViewController.h"

@interface UserRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) ConnectionProvider *cp;
@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSArray *countries;

@end

@implementation UserRegistrationViewController

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
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [self setTitle:@"Registration"];
    
    [super viewDidLoad];
    [_nameField setTag:0];
    [_phoneField setTag:1];
    [_emailField setTag:2];
    [_passwordField setTag:3];
    [_confirmPasswordField setTag:4];
    
    [_nameField setDelegate:self];
    [_phoneField setDelegate:self];
    [_emailField setDelegate:self];
    [_passwordField setDelegate:self];
    [_confirmPasswordField setDelegate:self];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    _countries = [NSArray arrayWithContentsOfFile:file];
    
    [self.countryPicker setDataSource:self];
    [self.countryPicker setDelegate:self];
    [self.countryPicker selectRow:218 inComponent:0 animated:NO];
    _countryCode = @"1";
    
    self.cp = [ConnectionProvider getInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)handleWhyClicked:(id)sender {

}

- (IBAction)register:(id)sender {
    //[LoginViewController setValidated:NO];
    [UserDefaultManager saveValidated:NO];
    
    NSArray *components = [_phoneField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    [UserDefaultManager saveCountryCode:_countryCode];
    NSString *username = [NSString stringWithFormat:@"%@-%@", _countryCode, [components componentsJoinedByString:@""]];
    NSArray *name = [_nameField.text componentsSeparatedByString:@" "];
    if (name.count < 2) {
        // Handle failed name validation
    }
    NSString *firstName = [name firstObject];
    NSString *lastName = [name lastObject];
    
    NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:username, VCARD_TAG_USERNAME, _passwordField.text, USER_DEFAULTS_PASSWORD, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, _emailField.text, VCARD_TAG_EMAIL, nil];
    [self.cp createAccount:accountInfo];
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
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *originalString = [textField.text substringWithRange:range];
    
    if (textField.tag == _nameField.tag) {
        return [self validateNameFieldChangeFromString:originalString toString:string];
    } else if(textField.tag == _phoneField.tag) {
        return [self validatePhoneFieldChangeFromString:originalString toString:string textField:textField range:range];
    } else if(textField.tag == _emailField.tag) {
        return [self validateEmailFieldChangeFromString:originalString toString:string];
    } else if(textField.tag == _passwordField.tag) {
        return [self validatePasswordFieldChangeFromString:originalString toString:string];
    } else if(textField.tag == _confirmPasswordField.tag) {
        return [self validateConfirmPasswordFieldChangeFromString:originalString toString:string];
    }
    return YES;
}

-(BOOL)validateNameFieldChangeFromString:(NSString*)originalString toString:(NSString*)newString {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z\\s\\'-]" options:NSRegularExpressionCaseInsensitive error:&error];
    if ([regex matchesInString:newString options:0 range:NSMakeRange(0, newString.length)].count > 0) {
        return NO;
    }
    return YES;
}

-(BOOL)validatePhoneFieldChangeFromString:(NSString*)originalString toString:(NSString*)string textField:(UITextField *)textField range:(NSRange)range {
    if (string.length == 0) {
        return YES;
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
    if ([regex matchesInString:string options:0 range:NSMakeRange(0, string.length)].count > 0) {
        return NO;
    }
    return YES;
}

-(BOOL)validateEmailFieldChangeFromString:(NSString*)originalString toString:(NSString*)newString {
    return YES;
}

-(BOOL)validatePasswordFieldChangeFromString:(NSString*)originalString toString:(NSString*)newString {
    return YES;
}

-(BOOL)validateConfirmPasswordFieldChangeFromString:(NSString*)originalString toString:(NSString*)newString {
    return YES;
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

- (IBAction)backToLogin:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
