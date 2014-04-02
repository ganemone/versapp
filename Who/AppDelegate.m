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

@implementation AppDelegate

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
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    @synchronized(self) {
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Who.sqlite"]];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
            NSLog(@"Failed to add persistent store type");
        }
    }
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (void)saveContextForBackgroundThreadWithMOC:(NSManagedObjectContext *)moc {
    NSManagedObjectContext *mainMoc = [self managedObjectContext];
    NSError *err = nil;
    if(![moc save:&err]) {
    }
    
    [mainMoc performBlock:^{
        NSError *error = nil;
        if (![mainMoc save:&error]) {
        }
    }];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString:@" " withString:@""]
                                    stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                   stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"Decoded Token String: %@", deviceTokenString);
    //[[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSetDeviceTokenPacket:deviceTokenString]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *stream = [cp getConnection];
    [self setupReachability];
    if ([stream isDisconnected]) {
        NSString *username = [UserDefaultManager loadUsername];
        NSString *password = [UserDefaultManager loadPassword];
        NSLog(@"User: %@", username);
        if (username != nil && password != nil) {
            //DashboardViewController *dashboard = [[DashboardViewController alloc] init];
            //[self.window setRootViewController:dashboard];
            [cp connect:username password:password];
        } else {
            //UserRegistrationViewController *registration = [[UserRegistrationViewController alloc] init];
            //[self.window setRootViewController:registration];
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
                [cp connect:[UserDefaultManager loadUsername] password:[UserDefaultManager loadPassword]];
            }
        });
        
    };
    [reach startNotifier];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification");
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Test Notification";
    [application presentLocalNotificationNow:notification];
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
