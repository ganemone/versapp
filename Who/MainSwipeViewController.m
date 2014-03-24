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
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ConfessionsViewController.h"
#import "Constants.h"
#import "StyleManager.h"
#import "FriendsDBManager.h"
#import "ChatDBManager.h"
#import "FriendMO.h"

#define NumViewPages 4

@interface MainSwipeViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageNavigationToFriends:) name:PAGE_NAVIGATE_TO_FRIENDS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageNavigationToMessages:) name:PAGE_NAVIGATE_TO_MESSAGES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageNavigationToConfessions:) name:PAGE_NAVIGATE_TO_CONFESSIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePageNavigationToContacts:) name:PAGE_NAVIGATE_TO_CONTACTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableInteraction) name:NOTIFICATION_DISABLE_SWIPE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableInteraction) name:NOTIFICATION_ENABLE_SWIPE object:nil];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Set the first controller to be shown
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    
    // Add the page view controller frame to the current view controller
    [_pageViewController.view setFrame:self.view.frame];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)handlePageNavigationToMessages:(NSNotification *)notification {
        UIPageViewControllerNavigationDirection direction = ((UIPageViewControllerNavigationDirection)[[notification.userInfo objectForKey:@"direction"] intValue]);
        [self handlePageNavigationToViewController:[self viewControllerAtIndex:0]
                                     direction:direction];
}

- (void)handlePageNavigationToConfessions:(NSNotification *)notification {
        UIPageViewControllerNavigationDirection direction = ((UIPageViewControllerNavigationDirection)[[notification.userInfo objectForKey:@"direction"] intValue]);
        [self handlePageNavigationToViewController:[self viewControllerAtIndex:1]
                                     direction:direction];
}

- (void)handlePageNavigationToFriends:(NSNotification *)notification {
        UIPageViewControllerNavigationDirection direction = ((UIPageViewControllerNavigationDirection)[[notification.userInfo objectForKey:@"direction"] intValue]);
        [self handlePageNavigationToViewController:[self viewControllerAtIndex:2]
                                     direction:direction];
}

- (void)handlePageNavigationToContacts:(NSNotification *)notification {
        UIPageViewControllerNavigationDirection direction = ((UIPageViewControllerNavigationDirection)[[notification.userInfo objectForKey:@"direction"] intValue]);
        [self handlePageNavigationToViewController:[self viewControllerAtIndex:3]
                                     direction:direction];
}

- (void)handlePageNavigationToViewController:(UIViewController*)controller direction:(UIPageViewControllerNavigationDirection)direction {
    __weak UIPageViewController *pvcw = _pageViewController;
    [_pageViewController setViewControllers:@[controller] direction:direction animated:YES completion:^(BOOL finished) {
        UIPageViewController *pvcs = pvcw;
        if (!pvcs) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [pvcs setViewControllers:@[controller] direction:direction animated:NO completion:nil];
        });
    }];
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

-(void)disableInteraction {
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            [scroll setScrollEnabled:NO];
        }
    }
}

-(void)enableInteraction {
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            [scroll setScrollEnabled:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
