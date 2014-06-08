//
//  ThoughtsTutorialViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/8/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtsTutorialViewController.h"
#import "StyleManager.h"

@interface ThoughtsTutorialViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation ThoughtsTutorialViewController

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
    [self.descriptionTextView setFont:[StyleManager getFontStyleLightSizeLarge]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
