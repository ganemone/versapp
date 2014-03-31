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

@interface NewUserRegisterUsernameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

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
}

- (void)handleFinishedRegisteringUsername {
    if ([Validator isValidUsername:_username.text]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_REGISTERING_USERNAME object:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Usernames must only contain Letters, numbers, and underscores." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
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

@end
