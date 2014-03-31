//
//  NewUserViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/30/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserViewController.h"
#import "ConnectionProvider.h"
#import "UserDefaultManager.h"
#import "Constants.h"
#import "NewUserRegisterNameViewController.h"
#import "NewUserRegisterPhoneViewController.h"
#import "NewUserRegisterUsernameViewController.h"

#define NumViewPages 4

@interface NewUserViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, strong) UIView *confessionView;

@end

@implementation NewUserViewController

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
    [self setupNotificationListeners];
    [self setupPageViewController];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)setupPageViewController {
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
}

- (void)setupNotificationListeners {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedRegisteringName:) name:NOTIFICATION_FINISHED_REGISTERING_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedRegisteringPhone:) name:NOTIFICATION_FINISHED_REGISTERING_PHONE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedRegisteringUsername:) name:NOTIFICATION_FINISHED_REGISTERING_USERNAME object:nil];
}

- (void)handleFinishedRegisteringName:(NSNotification *)notification {
    [_pageViewController setViewControllers:@[[_viewControllers objectAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringPhone:(NSNotification *)notification {
    [_pageViewController setViewControllers:@[[_viewControllers objectAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringUsername:(NSNotification *)notification {
    NSLog(@"Finished Registering Username...");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            storyboardID = STORYBOARD_ID_NEW_USER_REGISTER_NAME_VIEW_CONTROLLER; break;
        case 1:
            storyboardID = STORYBOARD_ID_NEW_USER_REGISTER_PHONE_VIEW_CONTROLLER; break;
        case 2:
            storyboardID = STORYBOARD_ID_NEW_USER_REGISTER_USERNAME_VIEW_CONTROLLER; break;
        case 3:
            storyboardID = STORYBOARD_ID_ENTER_CONFIRMATION_CODE_VIEW_CONTROLLER; break;
        default:
            return nil;
    }
    NSLog(@"Instantiating View Controller: %@", storyboardID);
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
    int index = 3;
    if ([viewController isKindOfClass:[NewUserRegisterNameViewController class]]) {
        index = 0;
    } else if([viewController isKindOfClass:[NewUserRegisterPhoneViewController class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[NewUserRegisterUsernameViewController class]]) {
        index = 2;
    }
    return index;
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
