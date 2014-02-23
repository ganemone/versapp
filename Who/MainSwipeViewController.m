//
//  MainSwipeViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/17/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MainSwipeViewController.h"
#import "DashboardViewController.h"
#import "FriendsViewController.h"
#import "ContactsViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"
#import "ConfessionsViewController.h"
#import "Constants.h"

#define NumViewPages 4

@interface MainSwipeViewController ()

@property UIPageViewController *pageViewController;

@end

@implementation MainSwipeViewController

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
    
    [self.navigationController setDelegate:self];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];

    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [_pageViewController.view setFrame:self.view.frame];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (UIViewController*)viewControllerAtIndex:(int)index {
    NSString *storyboardID;
    
    if (index > NumViewPages || index < 0) {
        return nil;
    }
    
    switch (index) {
        case 0:
            storyboardID = STORYBOARD_ID_DASHBOARD_VIEW_CONTROLLER; break;
        case 1:
            storyboardID = STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER; break;
        case 2:
            storyboardID = STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER; break;
        case 3:
            storyboardID = STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER; break;
        default:
            return nil;
    }
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
    return viewController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:viewController] - 1;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:viewController] + 1;
    if (index == 0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"grad-top-dark1.jpg"] forBarMetrics:UIBarMetricsDefault];
    } else if (index == 1) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"grad-top-dark1.jpg"] forBarMetrics:UIBarMetricsDefault];
    } else if (index == 2) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"grad-top-dark2.jpg"] forBarMetrics:UIBarMetricsDefault];
    } else if (index == 3) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"grad-top-dark1.jpg"] forBarMetrics:UIBarMetricsDefault];
    }
    return [self viewControllerAtIndex:index];
}

- (int)indexForViewController:(UIViewController*)viewController {
    int index = 0;
    if ([viewController isKindOfClass:[ConfessionsViewController class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[FriendsViewController class]]) {
        index = 2;
    } else if([viewController isKindOfClass:[ContactsViewController class]]) {
        index = 3;
    }
    return index;
}

/*-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return NumViewPages;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // -----------------
    // HACKY SOLUTION - Try to improve in the future
    // -----------------
    NSArray *childViewControllers = [[self pageViewController] childViewControllers];
    if ([childViewControllers count] > 2) {
        ConfessionsViewController *viewController;
        for (int i = 0; i < [childViewControllers count]; i++) {
            if ([[childViewControllers objectAtIndex:i] isKindOfClass:[ConfessionsViewController class]]) {
                viewController = [childViewControllers objectAtIndex:i];
                [viewController.tableView reloadData];
                i = [childViewControllers count];
            }
        }
    }
}

@end
