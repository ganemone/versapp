//
//  AppDelegate.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "AppDelegate.h"
#import "StyleManager.h"
#import "ConnectionProvider.h"
#import "UserDefaultManager.h"
#import "Constants.h"
#import "Reachability.h"
#import "MainSwipeViewController.h"
#import "ChatDBManager.h"
#import "AGPushNote/AGPushNoteView.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"
#import "ThoughtViewController.h"
#import "ConfessionsManager.h"
#import "MBProgressHUD.h"
#import "AppInitViewController.h"

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
    NSDictionary *pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if (pushDict) {
        [self handleRemoveNotification:pushDict];
    }
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *deviceTokenString = [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString:@" " withString:@""]
                                    stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                   stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    NSLog(@"Did register for remove notifications with device token: %@", deviceTokenString);
    
    [UserDefaultManager saveDeviceID:deviceTokenString];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Faild to register for remote notifications with error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [[[ConnectionProvider getInstance] getConnection] disconnectAfterSending];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    _localNotificationsOn = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _localNotificationsOn = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _didResumeFromBackground = YES;
    [self setup];
    
    NSLog(@"Creating timer");
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(acceptLocalNotifications) userInfo:nil repeats:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app applicationIconBadgeNumber] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_LOADING object:nil];
    }
    if (!(_didResumeFromBackground == YES)) {
        [self setup];
    }
    
    NSLog(@"Creating timer");
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(acceptLocalNotifications) userInfo:nil repeats:NO];
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
    _localNotificationsOn = NO;
    [self saveContext];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received Remote Notification: %@", userInfo);
    UIApplication *sharedApp = [UIApplication sharedApplication];
    if (!(application.applicationState == UIApplicationStateActive)) {
        [sharedApp setApplicationIconBadgeNumber:sharedApp.applicationIconBadgeNumber + 1];
        [self handleRemoveNotification:userInfo];
    }
}

-(void)handleRemoveNotification:(NSDictionary *)userInfo {
    NSString *cid = [userInfo objectForKey:@"cid"];
    if (cid != nil) {
        UIViewController *current = [AppDelegate getCurrentViewController];
        if (current == nil || [current isKindOfClass:AppInitViewController.class] || current.class == nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self handleRemoveNotification:userInfo];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.50 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showThoughtScreen:cid];
            });
        }
    }
}

-(void)showThoughtScreen:(NSString *)cid {
    ThoughtViewController *vc = [[ThoughtViewController alloc] initWithNibName:@"ThoughtViewController" bundle:nil];
    [[AppDelegate getCurrentViewController] presentViewController:vc animated:YES completion:nil];
    [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    [[ConfessionsManager getInstance] loadConfessionByID:cid withBlock:^(Confession *confession) {
        [vc setUpWithConfession:confession];
        [MBProgressHUD hideAllHUDsForView:vc.view animated:YES];
    }];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Received Local Notification: %@", notification.userInfo);
    if (_localNotificationsOn) {
        UIViewController *current = [AppDelegate getCurrentViewController];
        NSString *chatID = [notification.userInfo objectForKey:@"chat_id"];
        BOOL isMessageInCurrentChat = NO;
        
        if (chatID != nil) {
            if ([current isKindOfClass:ConversationViewController.class]) {
                isMessageInCurrentChat = [((ConversationViewController *)current).chatMO.chat_id isEqualToString:chatID];
            } else if ([current isKindOfClass:OneToOneConversationViewController.class]) {
                isMessageInCurrentChat = [((OneToOneConversationViewController *)current).chatMO.chat_id isEqualToString:chatID];
            }
        }
                                       
        
        if (![current isKindOfClass:JSMessagesViewController.class] ||
            !isMessageInCurrentChat)
        {
            [AGPushNoteView showWithNotificationMessage:notification.alertBody];
            [AGPushNoteView setMessageAction:^(NSString *message) {
                [self handleLocalNotificationClickedWithUserInfo:notification.userInfo];
            }];
        }
    }
}

-(void)handleLocalNotificationClickedWithUserInfo:(NSDictionary *)dictionary {
    UIViewController *currentVC = [AppDelegate getCurrentViewController];
    NSLog(@"CURRENT VC :%@", currentVC.class);
    if ([currentVC isKindOfClass:MainSwipeViewController.class])
    {
        NSLog(@"HERE");
        NSLog(@"Dictionary: %@", dictionary);
        NSString *type = [dictionary objectForKey:@"type"];
        if ([type isEqualToString:@"message"]) {
            [self handleLocalMessageNotification:dictionary fromVC:currentVC];
        } else if ([type isEqualToString:@"confession_favorited"]) {
            [self showThoughtScreen:[dictionary objectForKey:@"cid"]];
        } else if ([type isEqualToString:@"new_friend"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_FRIENDS object:nil];
        } else if ([type isEqualToString:@"invitation"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_MESSAGES object:nil];
        }
    }
    else if([currentVC isKindOfClass:ConversationViewController.class])
    {
        [currentVC.navigationController popToRootViewControllerAnimated:NO];
        [self handleLocalNotificationClickedWithUserInfo:dictionary];
    }
    else if([currentVC isKindOfClass:OneToOneConversationViewController.class])
    {
        [currentVC.navigationController popToRootViewControllerAnimated:NO];
        [self handleLocalNotificationClickedWithUserInfo:dictionary];
    }
}

-(void)handleLocalMessageNotification:(NSDictionary *)userInfo fromVC:(UIViewController *)currentVC {
    ChatMO *chat = [ChatDBManager getChatWithID:[userInfo objectForKey:@"chat_id"]];
    if ([chat.chat_type isEqualToString:CHAT_TYPE_GROUP])
    {
        [currentVC performSegueWithIdentifier:SEGUE_ID_MAIN_TO_GROUP sender:chat];
    }
    else
    {
        [currentVC performSegueWithIdentifier:SEGUE_ID_MAIN_TO_ONE_TO_ONE sender:chat];
    }
}

+ (UIViewController *)getCurrentViewController {
    //Check that new message's chat is not axlready open
    UIViewController *current = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (current.presentedViewController)
        current = current.presentedViewController;
    if ([current isKindOfClass:UINavigationController.class]) {
        current = ((UINavigationController *) current).visibleViewController;
    }
    return current;
}

-(void)acceptLocalNotifications {
    NSLog(@"Setting local notifications on");
    _localNotificationsOn = YES;
}




@end
