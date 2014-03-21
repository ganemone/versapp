//
//  UserRegistrationViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 3/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserRegistrationViewController.h"

@interface UserRegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

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
    /*
     [[self.cp getConnection] sendElement:[IQPacketManager createCreateVCardPacket:self.firstNameText lastname:self.lastNameText phone:self.usernameText email:self.emailText]];
     NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z\\s\\'-]" options:NSRegularExpressionCaseInsensitive error:&error];
     NSArray *matches = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
     NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:username, VCARD_TAG_USERNAME, password, USER_DEFAULTS_PASSWORD, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, email, VCARD_TAG_EMAIL, nil];
     [self.cp createAccount:accountInfo];*/
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
    NSLog(@"Original String: %@", originalString);
    NSLog(@"Replacement String: %@", string);
    
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
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    
    if (length == 0 || length > 10) {
        textField.text = decimalString;
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (length - index > 3) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    
    if (length - index > 3) {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    return NO;
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

@end
