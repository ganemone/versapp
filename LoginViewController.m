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
@property (strong, nonatomic) ConnectionProvider *connectionProviderInstance;
@end


@implementation LoginViewController

- (IBAction)login:(id)sender
{
    self.connectionProviderInstance = [ConnectionProvider getInstance];
    [self.connectionProviderInstance setController:self];
    [self.connectionProviderInstance connect:self.username.text password:self.password.text];
}

- (IBAction)test:(id)sender {
    MainTabBarController *main = [[MainTabBarController alloc] initWithNibName:@"MainTabBarController" bundle:nil];
    [self presentViewController:main animated:YES completion:NULL];
}

@end
