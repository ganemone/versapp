//
//  TutorialSlideViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TutorialSlideViewController.h"

@interface TutorialSlideViewController ()

@property (strong, nonatomic) UIImageView *imageView;

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
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_imageView];
        [self.imageView setImage:_image];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Position In Tutorial %d", _indexInTutorial);
    [self.imageView setImage:_image];
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
