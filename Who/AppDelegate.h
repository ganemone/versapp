//
//  AppDelegate.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *childObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *sessionID;
@property (strong, nonatomic) NSString *localNotificationMessage;

@property BOOL didResumeFromBackground;

- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectContext *)getManagedObjectContextForBackgroundThread;
- (void)saveContext;
- (void)saveContextForBackgroundThread;

@end
