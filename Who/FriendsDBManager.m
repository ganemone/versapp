//
//  FriendsDBManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendsDBManager.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "FriendMO.h"

@implementation FriendsDBManager

+(void)insert:(NSString *)username name:(NSString *)name status:(NSNumber *)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    FriendMO *friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    
    [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    
    [delegate saveContext];
}

+(NSArray *)getAll {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(NSArray *)getAllWithStatus:(NSNumber *)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_STATUS, status]];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

@end
