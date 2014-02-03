//
//  AppDelegate.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
<<<<<<< HEAD
=======
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;

-(NSArray*)getFriends;

-(NSArray*)getMessages;

- (void)insertMessage: (NSString*)group_id image_link:(NSString*)image_link message_body:(NSString*)message_body message_id:(NSInteger*) message_id reciever_id:(NSInteger*)reciever_id sender_id: (NSInteger*) sender_id time: (NSString*) time;
>>>>>>> CoreData

@end
