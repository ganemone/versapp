//
//  NewUserRegisterPhoneViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/30/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserRegisterPhoneViewController.h"
#import "Constants.h"
#import "PhoneVerificationManager.h"
#import "UserDefaultManager.h"

@interface NewUserRegisterPhoneViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;

@end

@implementation NewUserRegisterPhoneViewController

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
    [super setUp:_countryPicker countryCodeField:_countryCodeLabel];
    [_phone setDelegate:self];
    [_actionBtn addTarget:self action:@selector(handleFinishedRegisteringPhone) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_phone becomeFirstResponder];
}

-(NSString *)getSelectedCountry {
    return [super getCountryAtIndex:[_countryPicker selectedRowInComponent:0]];
}

-(NSString *)getSelectedCountryCode {
    return [super getCountryCodeAtIndex:[_countryPicker selectedRowInComponent:0]];
}

- (void)handleFinishedRegisteringPhone {
    if ([_phone.text length] > 0) {
        NSArray *components = [_phone.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *decimalString = [components componentsJoinedByString:@""];
        [UserDefaultManager savePhone:decimalString];
        [UserDefaultManager saveCountry:[self getSelectedCountry]];
        [UserDefaultManager saveCountryCode:[self getSelectedCountryCode]];
        PhoneVerificationManager *pvm = [[PhoneVerificationManager alloc] init];
        [pvm sendVerificationText];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_REGISTERING_PHONE object:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid phone number" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_countryPicker selectedRowInComponent:0] == 218) {
        NSString *originalString = [textField.text substringWithRange:range];
        return [self validatePhoneFieldChangeFromString:originalString toString:string textField:textField range:range];
    } else {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:NSRegularExpressionCaseInsensitive error:&error];
        if ([regex matchesInString:string options:0 range:NSMakeRange(0, string.length)].count > 0) {
            return NO;
        }
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
