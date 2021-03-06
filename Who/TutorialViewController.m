//
//  TutorialViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialSlideViewController.h"
#import "Constants.h"
#import "WelcomeViewController.h"
#import "ThoughtsTutorialViewController.h"
#import "SecurityTutorialViewController.h"
#import "GetStartedTutorialViewController.h"
#import "ConversationTypesViewController.h"

#define numPages 5

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
    [_pageViewController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 37.0)];
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
    [_pageControl setNumberOfPages:numPages];
    [self.view addSubview:_pageControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToLoginPage) name:SEGUE_ID_LOGIN_FROM_TUTORIAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoToRegisterPage) name:SEGUE_ID_REGISTER_FROM_TUTORIAL object:nil];
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
    TutorialSlideViewController *vc;
    switch (index) {
        case 0:vc = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil]; break;
        case 1:vc = [[ConversationTypesViewController alloc] initWithNibName:@"ConversationTypesViewController" bundle:nil]; break;
        case 2:vc = [[ThoughtsTutorialViewController alloc] initWithNibName:@"ThoughtsTutorialViewController" bundle:nil]; break;
        case 3:vc = [[SecurityTutorialViewController alloc] initWithNibName:@"SecurityTutorialViewController" bundle:nil]; break;
        default:vc = [[GetStartedTutorialViewController alloc] initWithNibName:@"GetStartedTutorialViewController" bundle:nil]; break;
    }
    [vc setIndexInTutorial:index];
    return vc;
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

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 5;
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

-(void)handleGoToRegisterPage {
    [self performSegueWithIdentifier:SEGUE_ID_REGISTER_FROM_TUTORIAL sender:nil];
}

-(void)handleGoToLoginPage {
    [self performSegueWithIdentifier:SEGUE_ID_LOGIN_FROM_TUTORIAL sender:nil];
}

@end
