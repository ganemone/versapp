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

- (void)saveContextWithMOC:(NSManagedObjectContext *)moc {
    NSError *error = nil;
    if ([moc hasChanges] && ![moc save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)handleConnectionLost {
    NSLog(@"Current Root View Controller: %@", [[self.window.rootViewController class] description]);
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
    NSLog(@"Is Connected? %d", [stream isConnected]);
    NSLog(@"Is Authenticated? %d", [stream isAuthenticated]);
    NSLog(@"Is Authenticating? %d", [stream isAuthenticating]);
    NSLog(@"Is Connecting? %d", [stream isConnecting]);
    NSLog(@"Is Disconnected? %d", [stream isDisconnected]);
    
    if ([stream isDisconnected]) {
        NSString *username = [UserDefaultManager loadUsername];
        NSString *password = [UserDefaultManager loadPassword];
        NSLog(@"User: %@", username);
        if (username != nil && password != nil) {
            [cp connect:username password:password];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"needToRegister" object:nil];
        }
    }
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
