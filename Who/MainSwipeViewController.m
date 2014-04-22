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
#import "ConfessionsManager.h"
#import "Confession.h"
#import "FriendsDBManager.h"

#define NumViewPages 4

@interface MainSwipeViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, strong) UIView *confessionView;
@property(nonatomic, strong) UIImageView *backgroundImageView;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpInBackground) name:PACKET_ID_GET_CONFESSIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableEditing) name:NOTIFICATION_ENABLE_DASHBOARD_EDITING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableEditing) name:NOTIFICATION_DISABLE_DASHBOARD_EDITING object:nil];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    self.viewControllers = @[[self viewControllerAtIndex:0], [self viewControllerAtIndex:1], [self viewControllerAtIndex:2], [self viewControllerAtIndex:3]];
    // Set the first controller to be shown
    [self.pageViewController setViewControllers:@[[_viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    // Add the page view controller frame to the current view controller
    [_pageViewController.view setFrame:self.view.frame];
    
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [_backgroundImageView setImage:[UIImage imageNamed:@"owl-left.png"]];
    [self.view addSubview:_backgroundImageView];
    [self.view sendSubviewToBack:_backgroundImageView];
    
    /*if ([[ConfessionsManager getInstance] getNumberOfConfessions] > 0) {
        [self setUpInBackground];
    }*/
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[ChatDBManager getNumForBadge]];
}

- (void)setUpInBackground {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ConfessionsManager *cm = [ConfessionsManager getInstance];
        CGSize contentSize = self.view.frame.size;
        NSArray *confessions = [[cm confessions] allValues];
        for (int i = 0; i < [confessions count]; i++) {
            [[confessions objectAtIndex:i] calculateFramesForTableViewCell:contentSize];
        }
    });
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

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *dest = [[pageViewController viewControllers] firstObject];
    if ([dest isKindOfClass:[ContactsViewController class]]) {
        [_backgroundImageView setImage:[UIImage imageNamed:@"owl-right.png"]];
    } else {
        [_backgroundImageView setImage:[UIImage imageNamed:@"owl-left.png"]];
    }
}

- (UIViewController*)viewControllerAtIndex:(int)index {
    NSString *storyboardID;
    
    if (index > NumViewPages || index < 0) {
        return nil;
    }
    
    if (_viewControllers != nil && [_viewControllers count] > index) {
        return [_viewControllers objectAtIndex:index];
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
    if ([viewController isKindOfClass:[ConfessionsViewController class]]) {
        self.confessionView = [viewController view];
    }
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

-(void)enableEditing {
    [_pageViewController.view removeFromSuperview];
    DashboardViewController *dashboard = (DashboardViewController *)[self.viewControllers objectAtIndex:0];
    [dashboard removeFromParentViewController];
    [self addChildViewController:dashboard];
    [self.view addSubview:[dashboard view]];
}

-(void)disableEditing {
    DashboardViewController *dashboard = (DashboardViewController *)[self.viewControllers objectAtIndex:0];
    [dashboard removeFromParentViewController];
    [_pageViewController setViewControllers:@[dashboard] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [_pageViewController addChildViewController:dashboard];
    [self.view addSubview:_pageViewController.view];
}





@end
