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

@property (weak, nonatomic) IBOutlet UITextView *headerTextView;
@property (weak, nonatomic) IBOutlet UITextView *groupTextView;
@property (weak, nonatomic) IBOutlet UITextView *invitedTextView;
@property (weak, nonatomic) IBOutlet UITextView *inviterTextView;
@property (weak, nonatomic) IBOutlet UITextView *thoughtTextView;

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
    [self.headerTextView setFont:[StyleManager getFontStyleBoldSizeLarge]];
    [self.groupTextView setFont:[StyleManager getFontStyleLightSizeMed]];
    [self.invitedTextView setFont:[StyleManager getFontStyleLightSizeMed]];
    [self.inviterTextView setFont:[StyleManager getFontStyleLightSizeMed]];
    [self.thoughtTextView setFont:[StyleManager getFontStyleLightSizeMed]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
