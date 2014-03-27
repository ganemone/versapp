//
//  EnterConfirmationViewController.m
//  Who
//
//  Created by Riley Lundquist on 3/24/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "EnterConfirmationViewController.h"
#import "Constants.h"
#import "UserDefaultManager.h"
#import "StyleManager.h"
#import "LoginViewController.h"

@interface EnterConfirmationViewController ()
@property (strong, nonatomic) IBOutlet UITextField *confirmationCodeField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UILabel *incorrectLabel;
@property (strong, nonatomic) NSString *confirmationCode;

@end

@implementation EnterConfirmationViewController

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
    
    [self sendCode];
}

- (IBAction)submitClicked:(id)sender {
    
    if ([self.confirmationCode compare:[self.confirmationCodeField text]] == 0) {
        //[UserDefaultManager saveValidated:YES];
        [LoginViewController setValidated:YES];
        [self performSegueWithIdentifier:SEGUE_ID_CONFIRMED sender:self];
    } else {
        [self.incorrectLabel setFont:[StyleManager getFontStyleBoldSizeMed]];
        [self.incorrectLabel setTextColor:[StyleManager getColorOrange]];
        [self.incorrectLabel setText:INVALID_CODE];
    }
}

-(void)sendCode {
    NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    self.confirmationCode = [self randomString:characters length:8];
    NSLog(@"%@", self.confirmationCode);
    
    //Text confirmationCode to user
}
-(NSString *)randomString:(NSString *)alphabet length:(NSUInteger)len {
    NSMutableString *s = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [NSString stringWithString:s];
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
