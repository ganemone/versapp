//
//  TutorialSlideViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TutorialSlideViewController.h"
#import "StyleManager.h"
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
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.view addSubview:_imageView];
        [self.imageView setImage:_image];
        
        if (_indexInTutorial == 5) {
            self.button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 60, self.view.frame.size.height - 50, 120, 20)];
            [self.button setTitle:@"Get Started" forState:UIControlStateNormal];
            [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.button.titleLabel setFont:[StyleManager getFontStyleLightSizeXL]];
            [self.button addTarget:self action:@selector(goToDashboard) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_button];
        }
        
    }
    return self;
}

- (void)goToDashboard {
    [[NSNotificationCenter defaultCenter] postNotificationName:SEGUE_ID_FINISHED_TUTORIAL object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
