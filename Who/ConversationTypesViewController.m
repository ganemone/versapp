//
//  ConversationTypesViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConversationTypesViewController.h"
#import "StyleManager.h"

@interface ConversationTypesViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextView *headerTextView;

@end

@implementation ConversationTypesViewController

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
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeTitle]];
    [self.headerTextView setFont:[StyleManager getFontStyleLightSizeLarge]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
