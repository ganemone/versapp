//
//  NewUserConfirmationCodeViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserConfirmationCodeViewController.h"
#import "UserDefaultManager.h"
#import "PhoneVerificationManager.h"
#import "Constants.h"

@interface NewUserConfirmationCodeViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *confirmationPicker;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) PhoneVerificationManager *pvm;
@property (weak, nonatomic) IBOutlet UITextView *textFieldBottom;
@property (weak, nonatomic) IBOutlet UITextView *textFieldTop;

@end

@implementation NewUserConfirmationCodeViewController

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
    [_confirmationPicker setDelegate:self];
    [_confirmationPicker setDataSource:self];
    self.pvm = [[PhoneVerificationManager alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (IBAction)actionBtnClicked:(id)sender {
    NSString *firstDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:0] forComponent:0];
    NSString *secondDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:1] forComponent:1];
    NSString *thirdDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:2] forComponent:2];
    NSString *fourthDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:3] forComponent:3];
    NSString *code = [NSString stringWithFormat:@"%@%@%@%@", firstDigit, secondDigit, thirdDigit, fourthDigit];
    if ([code isEqualToString:[_pvm loadVerificationCode]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_VERIFY_PHONE object:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Incorrect Verification Code." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)resendVerification:(id)sender {
    [_pvm sendVerificationText];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
