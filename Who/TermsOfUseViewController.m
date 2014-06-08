//
//  TermsOfUseViewController.m
//  Who
//
//  Created by Riley Lundquist on 2/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TermsOfUseViewController.h"
#import "StyleManager.h"

@interface TermsOfUseViewController ()
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TermsOfUseViewController

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
    [_header setFont:[StyleManager getFontStyleLightSizeXL]];
    [_header setTextColor:[UIColor whiteColor]];
    [_textView setFont:[StyleManager getFontStyleLightSizeMed]];
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
