//
//  NewUserRegisterUsernameViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/30/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserRegisterUsernameViewController.h"
#import "Constants.h"
#import "Validator.h"
#import "StyleManager.h"

@interface NewUserRegisterUsernameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation NewUserRegisterUsernameViewController

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
    [_username setDelegate:self];
    [_actionBtn addTarget:self action:@selector(handleFinishedRegisteringUsername) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    [_actionBtn.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [_registerBtn.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [_username setFont:[StyleManager getFontStyleLightSizeLarge]];
    [_descriptionTextView setFont:[StyleManager getFontStyleLightSizeLarge]];
    
    [_actionBtn.layer setCornerRadius:5.0];
    [_registerBtn.layer setCornerRadius:5.0];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_username becomeFirstResponder];
}

- (void)handleFinishedRegisteringUsername {
    if ([Validator isValidUsername:_username.text]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_REGISTERING_USERNAME object:nil];
        [self.view endEditing:YES];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Usernames must only contain Letters, numbers, and underscores." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Go to Tutorial"]) {
        if (!(buttonIndex == [alertView cancelButtonIndex])) {
            [self performSegueWithIdentifier:SEGUE_ID_TUTORIAL sender:self];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self handleFinishedRegisteringUsername];
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
