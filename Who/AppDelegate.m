//
//  AppDelegate.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "AppDelegate.h"
#import "ConnectionProvider.h"
#import "UserDefaultManager.h"
#import "Constants.h"
#import "UserRegistrationViewController.h"
#import "DashboardViewController.h"
#import "Reachability.h"
#import "IQPacketManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MainSwipeViewController.h"
#import "MessageMO.h"
#import "ChatDBManager.h"
#import "Encrypter.h"

@implementation AppDelegate

//void (^_completionHandler)(UIBackgroundFetchResult);

- (NSManagedObjectContext *) managedObjectContext {
    @synchronized(self) {
        if (_managedObjectContext != nil) {
            return _managedObjectContext;
        }
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectContext *) newManagedObjectContext {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    [moc setPersistentStoreCoordinator:coordinator];
    return moc;
}

-(NSManagedObjectContext *)getManagedObjectContextForBackgroundThread {
    @synchronized(self) {
        if (_childObjectContext != nil) {
            return _childObjectContext;
        }
        _childObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_childObjectContext setParentContext:[self managedObjectContext]];
        return _childObjectContext;
    }
}

- (NSManagedObjectModel *)managedObjectModel {
    @synchronized(self) {
        if (_managedObjectModel != nil) {
            return _managedObjectModel;
        }
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"db" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        return _managedObjectModel;
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized(self) {
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"db.sqlite"]];
        NSError *error = nil;
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES
                                  };
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
            NSLog(@"Error Setting Up Persistent Store Coordinator: %@", error);
        }
    }
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    [_managedObjectContext save:&error];
}

- (void)saveContextForBackgroundThread {
    [_childObjectContext save:nil];
    [_managedObjectContext performBlock:^{
        [_managedObjectContext save:nil];
    }];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSDictionary *pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString:@" " withString:@""]
                                    stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                   stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    [UserDefaultManager saveDeviceID:deviceTokenString];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [[[ConnectionProvider getInstance] getConnection] disconnect];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _didResumeFromBackground = YES;
    [self setup];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app applicationIconBadgeNumber] > 0) {
        NSLog(@"Has Messages to load");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_LOADING object:nil];
    }
    if (!(_didResumeFromBackground == YES)) {
        [self setup];
    }
}

- (void)setup {
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *stream = [cp getConnection];
    [self setupReachability];
    if ([stream isDisconnected]) {
        NSString *username = [UserDefaultManager loadUsername];
        NSString *password = [UserDefaultManager loadPassword];
        if (username != nil && password != nil) {
            [cp connect:username password:password];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"needToRegister" object:nil];
        }
    }
}

- (void)setupReachability {
    Reachability *reach = [Reachability reachabilityWithHostname:[ConnectionProvider getServerIPAddress]];
    reach.reachableOnWWAN = YES;
    reach.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[ConnectionProvider getInstance] getConnection] disconnect];
        });
    };
    reach.reachableBlock = ^(Reachability *reach) {
        ConnectionProvider *cp = [ConnectionProvider getInstance];
        XMPPStream *stream = [cp getConnection];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![stream isConnecting] && ![stream isAuthenticating] && ![stream isConnected] && ![stream isAuthenticated]) {
                NSString *username = [UserDefaultManager loadUsername];
                NSString *password = [UserDefaultManager loadPassword];
                if (username != nil && password != nil) {
                    [cp connect:username password:password];
                }
            }
        });
        
    };
    [reach startNotifier];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    _didResumeFromBackground = NO;
    [self saveContext];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplication *sharedApp = [UIApplication sharedApplication];
    [sharedApp setApplicationIconBadgeNumber:sharedApp.applicationIconBadgeNumber + 1];
}
// TODO remove content available from push notification
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UIApplication *sharedApp = [UIApplication sharedApplication];
    [sharedApp setApplicationIconBadgeNumber:sharedApp.applicationIconBadgeNumber + 1];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
