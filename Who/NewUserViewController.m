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
#import "Validator.h"
#import "PhoneVerificationManager.h"

@interface NewUserViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, strong) UIView *confessionView;
@property int numPages;
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
    self.connectionProvider = [ConnectionProvider getInstance];
    [self setupNotificationListeners];
    [self setupPageViewController];
    [self.navigationController.navigationBar setHidden:YES];
    PhoneVerificationManager *pvm = [[PhoneVerificationManager alloc] init];
}

- (void)setupPageViewController {
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    _numPages = 4;
    self.viewControllers = @[[self viewControllerAtIndex:0], [self viewControllerAtIndex:1], [self viewControllerAtIndex:2], [self viewControllerAtIndex:3]];
    _numPages = 1;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRegisteredUser) name:NOTIFICATION_DID_REGISTER_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToRegisterUser:) name:NOTIFICATION_DID_FAIL_TO_REGISTER_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticated) name:NOTIFICATION_AUTHENTICATED object:nil];
}

- (void)handleAuthenticated {
    NSLog(@"Authenticated");
}

- (void)handleRegisteredUser {
    NSLog(@"Sucessfully Registered User! Go to tutorial now");
}

- (void)handleFailedToRegisterUser:(NSNotification *)notification {
    NSLog(@"Failed to register user...");
}

- (void)handleFinishedRegisteringName:(NSNotification *)notification {
    _numPages = 2;
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringPhone:(NSNotification *)notification {
    _numPages = 3;
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringUsername:(NSNotification *)notification {
    NewUserRegisterNameViewController *nameVC = (NewUserRegisterNameViewController *)[self viewControllerAtIndex:0];
    NewUserRegisterPhoneViewController *phoneVC = (NewUserRegisterPhoneViewController *)[self viewControllerAtIndex:1];
    NewUserRegisterUsernameViewController *usernameVC = (NewUserRegisterUsernameViewController *)[self viewControllerAtIndex:2];
    NSString *name = [[nameVC name] text];
    NSString *email = [[nameVC email] text];
    NSString *password = [[nameVC password] text];
    NSString *confirm = [[nameVC confirmPassword] text];
    NSString *phone = [[phoneVC phone] text];
    NSString *username = [[usernameVC username] text];
    NSArray *components = [phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    phone = [components componentsJoinedByString:@""];
    NSString *country = [phoneVC getSelectedCountry];
    NSString *countryCode = [phoneVC getSelectedCountryCode];
    
    UIAlertView *alertView;
    
    if (![Validator isValidName:name]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidEmail:email]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidPasswordPair:password confirmPassword:confirm]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please make sure your passwords match, and are at least 6 digits long." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if (![Validator isValidPhoneNumber:phone]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid phone number" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    } else if (![Validator isValidUsername:username]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Usernames must only contain Letters, numbers, and underscores." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    if (alertView != nil) {
        [alertView show];
    } else {
        [self registerUserWithName:name
                             email:email
                             phone:phone
                          username:username
                          password:password
                           country:country
                       countryCode:countryCode];
    }
}

- (void)registerUserWithName:(NSString *)name
                       email:(NSString *)email
                       phone:(NSString *)phone
                    username:(NSString *)username
                    password:(NSString *)password
                     country:(NSString *)country
                 countryCode:(NSString *)countryCode
{
    [UserDefaultManager saveValidated:NO];
    [UserDefaultManager saveCountry:country];
    [UserDefaultManager saveCountryCode:countryCode];
    NSArray *nameArray = [name componentsSeparatedByString:@" "];
    NSString *firstName = [nameArray firstObject];
    NSString *lastName = [nameArray lastObject];
    
    NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:username, FRIENDS_TABLE_COLUMN_NAME_USERNAME, password, USER_DEFAULTS_PASSWORD, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, email, FRIENDS_TABLE_COLUMN_NAME_EMAIL, phone, FRIENDS_TABLE_COLUMN_NAME_PHONE, countryCode, USER_DEFAULTS_COUNTRY_CODE, nil];
    [self.connectionProvider createAccount:accountInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController*)viewControllerAtIndex:(int)index {
    NSString *storyboardID;
    NSLog(@"Looking at Index: %d With num pages: %d", index, _numPages);
    if (index >= _numPages || index < 0) {
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
