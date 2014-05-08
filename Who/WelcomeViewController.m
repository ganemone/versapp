//
//  WelcomeViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/8/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "WelcomeViewController.h"
#import "StyleManager.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *swipeLabel;

@end

@implementation WelcomeViewController

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
    [self.titleLabel setFont:[StyleManager getFontStyleLightSizeTitle]];
    [self.taglineLabel setFont:[StyleManager getFontStyleBoldSizeLarge]];
    [self.descriptionTextView setFont:[StyleManager getFontStyleLightSizeLarge]];
    [self.swipeLabel setFont:[StyleManager getFontStyleLightSizeMed]];
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
