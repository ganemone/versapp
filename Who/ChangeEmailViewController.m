//
//  ChangeEmailViewController.m
//  Who
//
//  Created by Riley Lundquist on 2/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface ChangeEmailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *updatedEmail;
@property (strong, nonatomic) IBOutlet UILabel *currentEmail;
@property (strong, nonatomic) ConnectionProvider *cp;

@end

@implementation ChangeEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.currentEmail setText:@"Current Email"/*get current email address*/];
}

- (IBAction)submitClicked:(id)sender {
    //Send update packet with all current info and new email
    //[[self.cp getConnection] sendElement:[IQPacketManager createUpdateVCardPacket:<#(NSString *)#> lastname:<#(NSString *)#> phone:<#(NSString *)#> email:<#(NSString *)#>]];
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
