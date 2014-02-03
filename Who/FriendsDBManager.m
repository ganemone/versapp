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

@implementation FriendsDBManager

+(void)insert:(NSString *)username name:(NSString *)name status:(NSNumber *)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObject *friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:[delegate managedObjectContext]];
    
    [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    
    NSError *error = NULL;
    [[delegate managedObjectContext] save:&error];
    if(error != NULL) {
        NSLog(@"Error Saving Data for Friend: %@", error);
    }
}

+(NSArray *)getAll {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:[delegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray *fetchedRecords = [[delegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(NSArray *)getAllWithStatus:(NSNumber *)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:[delegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(%@ = %@)", FRIENDS_TABLE_COLUMN_NAME_STATUS, status];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [[delegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

@end
