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
#import "Constants.h"
#import "StyleManager.h"
#import "UserDefaultManager.h"

@interface ChangeEmailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *updatedEmail;
@property (strong, nonatomic) IBOutlet UILabel *currentEmail;
@property (strong, nonatomic) IBOutlet UILabel *success;
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
    self.cp = [ConnectionProvider getInstance];
    [self.currentEmail setFont:[StyleManager getFontStyleBoldSizeMed]];
    [self.currentEmail setText:[UserDefaultManager loadEmail]];
}

- (IBAction)submitClicked:(id)sender {
    //Send update packet with all current info and new email
    NSLog(@"New Email: %@", self.updatedEmail.text);
    NSArray *names = [[UserDefaultManager loadName] componentsSeparatedByString:@" "];
    NSLog(@"Info: %@ %@ %@ %@", [names objectAtIndex:0], [names objectAtIndex:1], [UserDefaultManager loadUsername], [UserDefaultManager loadEmail]);
    [[self.cp getConnection] sendElement:[IQPacketManager createUpdateVCardPacket:[names objectAtIndex:0] lastname:[names objectAtIndex:1] phone:[UserDefaultManager loadUsername] email:self.updatedEmail.text]];
    [UserDefaultManager saveEmail:self.updatedEmail.text];
    [self.currentEmail setTextColor:[StyleManager getColorGreen]];
    [self.currentEmail setText:self.updatedEmail.text];
    [self.success setTextColor:[StyleManager getColorGreen]];
    [self.success setFont:[StyleManager getFontStyleBoldSizeMed]];
    [self.success setText:EMAIL_CHANGED];
    NSLog(@"Info: %@ %@ %@ %@", [names objectAtIndex:0], [names objectAtIndex:1], [UserDefaultManager loadUsername], [UserDefaultManager loadEmail]);
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
