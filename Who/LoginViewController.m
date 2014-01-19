//
//  LoginViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "LoginViewController.h"
#import "ConnectionProvider.h"
#import "MainTabBarController.h"
#import "RequestsViewController.h"

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (strong, atomic) ConnectionProvider *_connectionProviderInstance;
- (IBAction)loginClick:(id)sender;

//- (IBAction)loginClicked:(id)sender;
//@property ConnectionProvider *connectionProviderInstance;
@end


@implementation LoginViewController


-(void)authenticated
{
    [self performSegueWithIdentifier:@"Authenticated" sender:self];
}



/*-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSString *auth;
    //auth = @"Authenticated";
    self._connectionProviderInstance = [[ConnectionProvider alloc]init];
    //ConnectionProvider *connectionProviderInstance = [[ConnectionProvider alloc] init];
    [self._connectionProviderInstance connect:self.username.text password:self.password.text];
    
    
    if(self._connectionProviderInstance.authenticated == true)
    {
       auth = @"Authenticated";
    }
    
    if([identifier isEqualToString:auth])
    {
        return YES;
    }
    return NO;
}*/


- (IBAction)loginClick:(id)sender {
    
   self._connectionProviderInstance = [[ConnectionProvider alloc]init];
   [self._connectionProviderInstance connect:self.username.text password:self.password.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticated) name:@"authenticated" object:nil];    
}

@end
