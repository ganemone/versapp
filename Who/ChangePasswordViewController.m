//
//  ChangePasswordViewController.m
//  Who
//
//  Created by Riley Lundquist on 2/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Constants.h"
#import "StyleManager.h"
#import "UserDefaultManager.h"

@interface ChangePasswordViewController ()
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UITextField *currentPassword;
@property (strong, nonatomic) IBOutlet UITextField *updatedPassword;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassword;
@property (strong, nonatomic) IBOutlet UIButton *submit;
@property (strong, nonatomic) IBOutlet UILabel *success;

@end

@implementation ChangePasswordViewController

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
	// Do any additional setup after loading the view.
    
    self.currentPassword.secureTextEntry = YES;
    self.updatedPassword.secureTextEntry = YES;
    self.confirmPassword.secureTextEntry = YES;
}

- (IBAction)submitClicked:(id)sender {
    if ([self.updatedPassword.text compare:self.confirmPassword.text] == 0) {
        [UserDefaultManager savePassword:self.updatedPassword.text];
        
        [self.success setTextColor:[StyleManager getColorGreen]];
        [self.success setFont:[StyleManager getFontStyleBoldSizeMed]];
        [self.success setText:PASSWORD_CHANGED];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
