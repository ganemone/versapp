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

@implementation AppDelegate

void (^_completionHandler)(UIBackgroundFetchResult);

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
    // Let the device know we want to receive push notifications
    NSDictionary *pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"Push Dict: %@", [pushDict description]);
    
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    _completionHandler = completionHandler;
    _localNotificationMessage = [userInfo objectForKey:@"message"];
    //NSLog(@"Received remote notification");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedLoadingContentForNotification:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    //NSLog(@"Registered First Receiver");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedLoadingContentForNotification:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    //NSLog(@"Registered Second Receiver");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFailedToLoadDataAfterRemoteNotification) name:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    //NSLog(@"Registered Third Receiver");
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    //NSLog(@"Got CP");
    XMPPStream *stream = [cp getConnection];
    //NSLog(@"Got Stream");
    if (![stream isAuthenticated]) {
        //NSLog(@"Going to connect...");
        NSString *username = [UserDefaultManager loadUsername];
        NSString *password = [UserDefaultManager loadPassword];
        [cp connectForPushNotificationFetch:username password:password];
    } else {
        _completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)handleFinishedLoadingContentForNotification:(NSNotification *)notification {
    /*UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    //MessageMO *message = [notification.userInfo objectForKey:DICTIONARY_KEY_MESSAGE_OBJECT];
    //localNotification.userInfo = [NSDictionary dictionaryWithObject:message.group_id forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
    localNotification.alertBody = _localNotificationMessage;
    //localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    UIApplication *sharedApp = [UIApplication sharedApplication];
    [sharedApp scheduleLocalNotification:localNotification];
    [sharedApp setApplicationIconBadgeNumber:sharedApp.applicationIconBadgeNumber + 1];*/
    _completionHandler(UIBackgroundFetchResultNewData);
}

- (void)handleFailedToLoadDataAfterRemoteNotification {
    _completionHandler(UIBackgroundFetchResultFailed);
}

@end
