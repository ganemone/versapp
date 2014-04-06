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
@property (strong, nonatomic) IBOutlet UITextField *confirmationField;

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
    self.pvm = [[PhoneVerificationManager alloc] init];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBtnClicked:(id)sender {
    if ([self.confirmationField.text isEqualToString:[_pvm loadVerificationCode]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_VERIFY_PHONE object:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Incorrect Verification Code." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)resendVerification:(id)sender {
    [_pvm sendVerificationText];
    [[[UIAlertView alloc] initWithTitle:@"Sent!" message:@"We resent the verification code to your phone. Still having dificulties? Make sure you have the correct country selected." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
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
