//
//  EnterConfirmationViewController.m
//  Who
//
//  Created by Riley Lundquist on 3/24/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "EnterConfirmationViewController.h"
#import "Constants.h"

@interface EnterConfirmationViewController ()
@property (strong, nonatomic) IBOutlet UITextField *confirmationCodeField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

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
}

- (IBAction)submitClicked:(id)sender {
    
    //VERIFY THAT CODES MATCH
     
    [self.navigationController popToRootViewControllerAnimated:YES];
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
