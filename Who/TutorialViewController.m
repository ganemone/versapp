//
//  TutorialViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TutorialViewController.h"
#import "UserDefaultManager.h"
#import "TutorialSlideViewController.h"
#import "Constants.h"
#import "SMPageControl.h"

#define numPages 5

@interface TutorialViewController ()

@property UIPageViewController *pageViewController;
@property NSMutableArray *viewControllers;

@end

@implementation TutorialViewController

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
    self.viewControllers = [[NSMutableArray alloc] initWithCapacity:numPages];
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    // Add the page view controller frame to the current view controller
    [_pageViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30)];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
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

- (UIViewController*)viewControllerAtIndex:(int)index {
    if (index >= numPages || index < 0) {
        return nil;
    }
    /*if ([_viewControllers count] <= index) {
        [_viewControllers addObject:[[TutorialSlideViewController alloc] initWithImage:[self imageForViewControllerAtIndex:index] indexInTutorial:index]];
    }*/
    return [[TutorialSlideViewController alloc] initWithImage:[self imageForViewControllerAtIndex:index] indexInTutorial:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:(TutorialSlideViewController *)viewController] - 1;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:(TutorialSlideViewController *)viewController] + 1;
    return [self viewControllerAtIndex:index];
}

-(int)indexForViewController:(TutorialSlideViewController *)viewController {
    return [viewController indexInTutorial];
}

-(UIImage *)imageForViewControllerAtIndex:(int)index {
    switch (index) {
        case 0: return [UIImage imageNamed:@"AppIcon120.png"];
        case 1: return [UIImage imageNamed:@"loading640x960.png"];
        case 2: return [UIImage imageNamed:@"AppIcon120.png"];
        case 3: return [UIImage imageNamed:@"loading640x960.png"];
        default: return [UIImage imageNamed:@"AppIcon120.png"];
    }
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 5;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
