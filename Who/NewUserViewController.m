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
#import "NewUserConfirmationCodeViewController.h"
#import "Validator.h"
#import "PhoneVerificationManager.h"
#import "MBProgressHUD.h"
#import "StyleManager.h"
#import "Encrypter.h"

@interface NewUserViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) NSArray *viewControllers;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *confirm;
@property(nonatomic, strong) NSString *phone;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *country;
@property(nonatomic, strong) NSString *countryCode;
@property(nonatomic, strong) MBProgressHUD *loadingDialog;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerUser) name:NOTIFICATION_PHONE_AVAILABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePhoneUnavailable) name:NOTIFICATION_PHONE_UNAVAILABLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredVerificationCode) name:NOTIFICATION_DID_VERIFY_PHONE object:nil];
}

- (void)handlePhoneUnavailable {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"The phone number you picked has already been registered for an account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)handleAuthenticated {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:SEGUE_ID_FINISHED_TUTORIAL sender:self];
}

- (void)handleRegisteredUser {
    [self.loadingDialog setLabelText:@"Logging in"];
}

- (void)handleFailedToRegisterUser:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    NSString *message = [notification.userInfo objectForKey:DICTIONARY_KEY_ERROR_MESSAGE];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
}

- (void)handleFinishedRegisteringName:(NSNotification *)notification {
    _numPages = 2;
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringPhone:(NSNotification *)notification {
    _numPages = 3;
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleEnteredVerificationCode {
    _numPages = 4;
    [_pageViewController setViewControllers:@[[self viewControllerAtIndex:3]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)handleFinishedRegisteringUsername:(NSNotification *)notification {
    NewUserRegisterNameViewController *nameVC = (NewUserRegisterNameViewController *)[self viewControllerAtIndex:0];
    NewUserRegisterPhoneViewController *phoneVC = (NewUserRegisterPhoneViewController *)[self viewControllerAtIndex:1];
    NewUserRegisterUsernameViewController *usernameVC = (NewUserRegisterUsernameViewController *)[self viewControllerAtIndex:3];
    _name = [[nameVC name] text];
    _email = [[nameVC email] text];
    _password = [[nameVC password] text];
    _confirm = [[nameVC confirmPassword] text];
    _phone = [[phoneVC phone] text];
    _username = [[usernameVC username] text];
    NSArray *components = [_phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    _phone = [components componentsJoinedByString:@""];
    _country = [phoneVC getSelectedCountry];
    _countryCode = [phoneVC getSelectedCountryCode];
    UIAlertView *alertView;
    
    if (![Validator isValidName:_name]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid name." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidEmail:_email]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if(![Validator isValidPasswordPair:_password confirmPassword:_confirm]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please make sure your passwords match, and are at least 6 digits long." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    } else if (![Validator isValidPhoneNumber:_phone]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Please enter a valid phone number" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    } else if (![Validator isValidUsername:_username]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Usernames must only contain Letters, numbers, and underscores." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    if (alertView != nil) {
        [alertView show];
    } else {
        _loadingDialog = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_loadingDialog setLabelFont:[StyleManager getFontStyleLightSizeXL]];
        [_loadingDialog setLabelText:@"Registering User"];
        
        PhoneVerificationManager *pvm = [[PhoneVerificationManager alloc] init];
        [pvm checkForPhoneRegisteredOnServer:_countryCode phone:_phone];
    }
}

- (void)registerUser {
    [UserDefaultManager saveValidated:NO];
    [UserDefaultManager saveCountry:_country];
    [UserDefaultManager saveCountryCode:_countryCode];
    NSArray *nameArray = [_name componentsSeparatedByString:@" "];
    NSString *firstName = [nameArray firstObject];
    NSString *lastName = [nameArray lastObject];
    _password = [Encrypter md5:_password];

    NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:_username, FRIENDS_TABLE_COLUMN_NAME_USERNAME, _password, USER_DEFAULTS_PASSWORD, firstName, VCARD_TAG_FIRST_NAME, lastName, VCARD_TAG_LAST_NAME, _email, FRIENDS_TABLE_COLUMN_NAME_EMAIL, _phone, FRIENDS_TABLE_COLUMN_NAME_PHONE, _countryCode, USER_DEFAULTS_COUNTRY_CODE, nil];
    [self.connectionProvider createAccount:accountInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController*)viewControllerAtIndex:(int)index {
    NSString *storyboardID;
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
            storyboardID = STORYBOARD_ID_NEW_USER_CONFIRMATION_CODE_VIEW_CONTROLLER; break;
        case 3:
            storyboardID = STORYBOARD_ID_NEW_USER_REGISTER_USERNAME_VIEW_CONTROLLER; break;
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
    int index = 3;
    if ([viewController isKindOfClass:[NewUserRegisterNameViewController class]]) {
        index = 0;
    } else if([viewController isKindOfClass:[NewUserRegisterPhoneViewController class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[NewUserConfirmationCodeViewController class]]) {
        index = 2;
    }
    return index;
}

@end
