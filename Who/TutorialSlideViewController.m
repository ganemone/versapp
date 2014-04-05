//
//  TutorialSlideViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TutorialSlideViewController.h"
#import "Constants.h"

@interface TutorialSlideViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *button;
@end

@implementation TutorialSlideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage *)image indexInTutorial:(int)indexInTutorial {
    self = [super init];
    if (self) {
        self.image = image;
        self.indexInTutorial = indexInTutorial;
        //self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        //[self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        //[self.view addSubview:_imageView];
        //[self.imageView setImage:_image];
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.imageView setImage:_image];
    //if (self.indexInTutorial == 5) {
        [_button setTitle:@"Get Started" forState:UIControlStateNormal];
        [_button setTintColor:[UIColor blackColor]];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[_button addTarget:self action:@selector(goToDashboard) forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:_button];
        [self.view bringSubviewToFront:_button];
        [self.view sendSubviewToBack:_imageView];
    //}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToDashboard {
    [self performSegueWithIdentifier:SEGUE_ID_FINISHED_TUTORIAL sender:self];
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
