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

+(void)insert:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    FriendMO *friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    
    [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
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

+(FriendMO *)getUserWithEmail:(NSString *)email {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = %@", FRIENDS_TABLE_COLUMN_NAME_EMAIL, email]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}


+(FriendMO *)getUserWithJID:(NSString *)jid {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = %@", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(BOOL)hasUserWithEmail:(NSString *)email {
    return ([self getUserWithEmail:email] != nil);
}

+(BOOL)hasUserWithJID:(NSString *)jid {
    return ([self getUserWithJID:jid] != nil);
}

+(BOOL)updateEntry:(NSString *)username name:(NSString *)name email:(NSString *)email status:(NSNumber *)status {
    FriendMO *friend = [self getUserWithJID:username];
    if (friend == nil) {
        return NO;
    }

    [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
    [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate saveContext];
    
    return YES;
}



+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(BOOL)updateUserStatus:(NSString*) username status:(NSNumber*)status {
    FriendMO *entry = [self getUserWithJID:username];
    if (entry == nil) {
        return NO;
    }
    [entry setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate saveContext];
    return YES;
}

+(BOOL)updateUserSetStatusFriends:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_FRIENDS]];
}

+(BOOL)updateUserSetStatusPending:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_PENDING]];
}

+(BOOL)updateUserSetStatusRegistered:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_REGISTERED]];
}

+(BOOL)updateUserSetStatusRejected:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_REJECTED]];
}

+(BOOL)updateUserSetStatusUnregistered:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_UNREGISTERED]];
}

+(NSArray*)getAllWithStatusFriends {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_FRIENDS]];
}

+(NSArray*)getAllWithStatusPending {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_PENDING]];
}

+(NSArray*)getAllWithStatusRegistered {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_REGISTERED]];
}

+(NSArray*)getAllWithStatusRejected {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_REJECTED]];
}

+(NSArray*)getAllWithStatusUnregistered {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_UNREGISTERED]];
}

@end
