//
//  GetStartedTutorialViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/8/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GetStartedTutorialViewController.h"
#import "StyleManager.h"
#import "Constants.h"
@interface GetStartedTutorialViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation GetStartedTutorialViewController

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
    [self.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SEGUE_ID_REGISTER_FROM_TUTORIAL object:nil];
}

- (IBAction)loginBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SEGUE_ID_LOGIN_FROM_TUTORIAL object:nil];
}

@end
