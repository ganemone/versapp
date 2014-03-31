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
    [self.navigationController.navigationBar setHidden:YES];
    
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
    int index = 0;
    if ([viewController isKindOfClass:[self class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[self class]]) {
        index = 2;
    } else if([viewController isKindOfClass:[self class]]) {
        index = 3;
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
