//
//  ThoughtViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 9/8/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtViewController.h"
#import "StyleManager.h"

@interface ThoughtViewController ()

@end

@implementation ThoughtViewController

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
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [self.headerLabel setTextColor:[UIColor whiteColor]];
}

- (void)setUpWithConfession:(Confession *)confession {
    _confession = confession;
    ThoughtTableViewCell * cell = [StyleManager createThoughtViewWithConfession:_confession];
    CGSize size = cell.frame.size;
    [cell setFrame:CGRectMake(0, 64, size.width, size.height)];
    [self.view addSubview:cell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnPressed:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
