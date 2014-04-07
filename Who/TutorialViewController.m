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

#define numPages 6

@interface TutorialViewController ()

@property UIPageViewController *pageViewController;
@property NSMutableArray *viewControllers;
@property UIPageControl *pageControl;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToDashboard) name:SEGUE_ID_FINISHED_TUTORIAL object:nil];
    
    self.viewControllers = [[NSMutableArray alloc] initWithCapacity:numPages];
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    // Add the page view controller frame to the current view controller
    [_pageViewController.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37.0)];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSArray *subviews = self.pageViewController.view.subviews;
    UIPageControl *oldPageControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            oldPageControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    [oldPageControl removeFromSuperview];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 10)];
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    //[_pageControl setTintColor:[UIColor blackColor]];
    //[_pageControl setPageIndicatorTintColor:[UIColor blackColor]];
    //[_pageControl setCurrentPageIndicatorTintColor:[UIColor blueColor]];
    [_pageControl setNumberOfPages:5];
    [self.view addSubview:_pageControl];
}

- (void)goToDashboard {
    [self performSegueWithIdentifier:SEGUE_ID_FINISHED_TUTORIAL sender:self];
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
        case 0: return [UIImage imageNamed:@"Versapp-Tutorial-01.png"];
        case 1: return [UIImage imageNamed:@"Versapp-Tutorial-02.png"];
        case 2: return [UIImage imageNamed:@"Versapp-Tutorial-03.png"];
        case 3: return [UIImage imageNamed:@"Versapp-Tutorial-04.png"];
        case 4: return [UIImage imageNamed:@"Versapp-Tutorial-05.png"];
        default: return [UIImage imageNamed:@"Versapp-Tutorial-06.png"];
    }
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 6;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    [_pageControl setCurrentPage:[(TutorialSlideViewController *)[pendingViewControllers firstObject] indexInTutorial]];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    [_pageControl setCurrentPage:[(TutorialSlideViewController *)[pageViewController.viewControllers firstObject] indexInTutorial]];
}

@end
