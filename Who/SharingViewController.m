//
//  SharingViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/10/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "SharingViewController.h"
#import "SocialSharingManager.h"
#import "StyleManager.h"
#import "Constants.h"

@interface SharingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIButton *backArrowBtn;

@end

@implementation SharingViewController

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
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    [self.descriptionTextView setFont:[StyleManager getFontStyleRegularSizeLarge]];
    [self.facebookBtn.titleLabel setFont:[StyleManager getFontStyleRegularSizeLarge]];
    [self.twitterBtn.titleLabel setFont:[StyleManager getFontStyleRegularSizeLarge]];
    [self.twitterBtn.layer setCornerRadius:5.0];
    [self.facebookBtn.layer setCornerRadius:5.0];
    [self.backArrowBtn.layer setCornerRadius:5.0];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"contacts-background-large.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
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
- (IBAction)backBtnPressed:(id)sender
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionReverse], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_FRIENDS
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)shareOnFacebook:(id)sender
{
    [SocialSharingManager shareVersappFBLink];
}

- (IBAction)shareOnTwitter:(id)sender
{
    [self presentViewController:[SocialSharingManager getTweetSheet] animated:YES completion:nil];
}

@end
