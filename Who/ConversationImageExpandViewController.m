//
//  ConversationImageExpandViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConversationImageExpandViewController.h"

@interface ConversationImageExpandViewController ()

@end

@implementation ConversationImageExpandViewController

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
    NSLog(@"Self Image: %@", self.selectedImage);
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView setImage:self.selectedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
