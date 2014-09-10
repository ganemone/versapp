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

+(FriendMO *)insert:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail uid:(NSNumber *)uid {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    FriendMO *friend;
    //if (uid != nil) {
        //friend = [self getUserWithUID:uid];
    //} else {
        friend = (email == nil) ? [self getUserWithUsername:username] : [self getUserWithUsername:username email:email];
    //}
    if (friend == nil) {
        friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    } else {
    }
    if (username != nil && friend.username == nil) {
        [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    }
    if (name != nil) {
        [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    }
    if (email != nil) {
        [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
    }
    if (status != nil) {
        [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    }
    if (searchedPhoneNumber != nil) {
        [friend setValue:searchedPhoneNumber forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
    }
    if (searchedEmail != nil) {
        [friend setValue:searchedEmail forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
    }
    if (uid != nil) {
        [friend setValue:uid forKey:FRIENDS_TABLE_COLUMN_NAME_UID];
    }
    
    [delegate saveContext];
    return friend;
}

+ (BOOL)hasEnoughFriends {
    return ([[self getAllWithStatusFriends] count] >= 3);
}

+ (void)updateFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSNumber *status = friend[FRIENDS_TABLE_COLUMN_NAME_STATUS];
    if ([status isEqualToNumber:@(STATUS_REGISTERED)]) {
        [self updateRegisteredFriendAfterUserSearch:friend withContext:moc];
    } else {
        [self updateUnregisteredFriendAfterUserSearch:friend withContext:moc];
    }
}

+ (void)updateRegisteredFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSString *username = friend[FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", friend[VCARD_TAG_FIRST_NAME], friend[VCARD_TAG_LAST_NAME]];
    FriendMO *friendMO = [self getUserWithUsername:username moc:moc];
    if (friendMO == nil) {
        [self insertWithMOC:moc
                   username:username
                       name:fullName
                      email:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]
                     status:@(STATUS_REGISTERED)
        searchedPhoneNumber:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER]
              searchedEmail:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]
                        uid:friend[FRIENDS_TABLE_COLUMN_NAME_UID]];
    } else {
        [friendMO setValue:username forKeyPath:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
        [friendMO setValue:fullName forKeyPath:FRIENDS_TABLE_COLUMN_NAME_NAME];
        [friendMO setValue:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        if ([friendMO.status isEqualToNumber:@(STATUS_UNREGISTERED)]) {
            [friendMO setValue:@(STATUS_REGISTERED) forKeyPath:FRIENDS_TABLE_COLUMN_NAME_STATUS];
        }
        [friendMO setValue:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
    }
}

+ (void)updateUnregisteredFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSString *searchedPhoneNumber = [friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER] firstObject];
    NSString *searchedEmail = [friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] firstObject];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", friend[VCARD_TAG_FIRST_NAME], friend[VCARD_TAG_LAST_NAME]];
    NSArray *friends;
    if (searchedPhoneNumber != nil && searchedPhoneNumber.length > 0) {
        friends = [self getUserWithSearchedPhoneNumber:searchedPhoneNumber withMOC:moc];
    } else {
        friends = [self getUserWithSearchedEmail:searchedEmail withMOC:moc];
    }
    if (friends.count > 0) {
        for (FriendMO *friendMO in friends) {
            [friendMO setValue:fullName forKeyPath:FRIENDS_TABLE_COLUMN_NAME_NAME];
            [friendMO setValue:searchedEmail forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
            [friendMO setValue:searchedPhoneNumber forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
            if (friendMO.status == nil) {
                [friendMO setValue:@(STATUS_UNREGISTERED) forKeyPath:FRIENDS_TABLE_COLUMN_NAME_STATUS];
            }
        }
    } else {
        [self insertWithMOC:moc
                   username:nil
                       name:fullName
                      email:friend[FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]
                     status:@(STATUS_UNREGISTERED)
        searchedPhoneNumber:searchedPhoneNumber
              searchedEmail:searchedEmail
                        uid:friend[FRIENDS_TABLE_COLUMN_NAME_UID]];
    }
}

+ (NSArray *)getUserWithSearchedPhoneNumber:(NSString *)phoneNumber withMOC:(NSManagedObjectContext *)moc {
    return [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER, phoneNumber] moc:moc];
}

+ (NSArray *)getUserWithSearchedEmail:(NSString *)email withMOC:(NSManagedObjectContext *)moc {
    return [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL, email] moc:moc];
}

+ (BOOL)insertWithMOC:(NSManagedObjectContext *)moc username:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail uid:(NSNumber *)uid {
    
    FriendMO *friend;
    //if (uid != nil) {
        //friend = [self getUserWithUID:uid withMOC:moc];
    //} else {
        friend = (email == nil) ? [self getUserWithUsername:username moc:moc] : [self getUserWithUsername:username email:email moc:moc];
    //}
    BOOL ret = (friend == nil);
    if (friend == nil) {
        friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    }
    if (username != nil) {
        [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    }
    if (name != nil) {
        [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    }
    if (email != nil) {
        [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
    }
    if (status != nil) {
        [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    }
    if (searchedPhoneNumber != nil) {
        [friend setValue:searchedPhoneNumber forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
    }
    if (searchedEmail != nil) {
        [friend setValue:searchedEmail forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
    }
    if (uid != nil) {
        [friend setValue:uid forKey:FRIENDS_TABLE_COLUMN_NAME_UID];
    }
    BOOL returnValue = (ret || friend.name == nil);
    return returnValue;
}

/*
+(NSArray *)getAll {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}
*/

+(NSArray *)getAllWithStatus:(NSNumber *)status {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:FRIENDS_TABLE_COLUMN_NAME_NAME ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_STATUS, status]];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(FriendMO *)getUserWithEmail:(NSString *)email {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_EMAIL, email]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithUsername:(NSString *)jid {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

/*
+(FriendMO *)getUserWithEmail:(NSString *)email moc:(NSManagedObjectContext *)moc  {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_EMAIL, email] moc:moc];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}
*/

+(FriendMO *)getUserWithUsername:(NSString *)username moc:(NSManagedObjectContext *)moc  {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, username] moc:moc];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithUsername:(NSString *)jid email:(NSString *)email {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" OR %@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid, FRIENDS_TABLE_COLUMN_NAME_EMAIL, email]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithUsername:(NSString *)jid email:(NSString *)email moc:(NSManagedObjectContext *)moc {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" OR %@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid, FRIENDS_TABLE_COLUMN_NAME_EMAIL, email] moc:moc];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

/*
+(BOOL)hasUserWithEmail:(NSString *)email {
    return ([self getUserWithEmail:email] != nil);
}
*/

+(BOOL)hasUserWithJID:(NSString *)jid {
    return ([self getUserWithUsername:jid] != nil);
}

+(BOOL)updateEntry:(NSString *)username name:(NSString *)name email:(NSString *)email status:(NSNumber *)status {
    FriendMO *friend = [self getUserWithUsername:username];
    if (friend == nil) {
        return NO;
    }
    
    [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
    [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
    [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate saveContext];
    
    return YES;
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString moc:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:2];
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    return [self makeFetchRequest:predicateString moc:moc];
}

+(NSArray*)makeFetchRequestWithPredicate:(NSPredicate*)predicate {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(BOOL)updateUserStatus:(NSString*) username status:(NSNumber*)status {
    FriendMO *entry = [self getUserWithUsername:username];
    if (entry == nil) {
        return NO;
    }
    [entry setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate saveContext];
    return YES;
}

+(BOOL)updateUserSetStatusFriends:(NSString *)username {
    return [self updateUserStatus:username status:@(STATUS_FRIENDS)];
}

+(BOOL)updateUserSetStatusRejected:(NSString *)username {
    return [self updateUserStatus:username status:@(STATUS_REJECTED)];
}

+(BOOL)updateUserSetStatusRequested:(NSString *)username {
    return [self updateUserStatus:username status:@(STATUS_REQUESTED)];
}

+(BOOL)updateUserSetStatusInvited:(NSString *)username {
    return [self updateUserStatus:username status:@(STATUS_INVITED)];
}

+(NSArray*)getAllWithStatusFriends {
    return [self getAllWithStatus:@(STATUS_FRIENDS)];
}

+(NSArray*)getAllWithStatusPending {
    return [self getAllWithStatus:@(STATUS_PENDING)];
}

/*
+(NSArray*)getAllWithStatusRegistered {
    return [self getAllWithStatus:@(STATUS_REGISTERED)];
}
*/

+(void)deleteUserWithUsername:(NSString *)username {
    FriendMO *friend = [FriendsDBManager getUserWithUsername:username];
    [FriendsDBManager deleteUser:friend];
}

+ (void)deleteUser:(FriendMO *)friend {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (friend != nil) {
        [[delegate managedObjectContext] deleteObject:friend];
        [delegate saveContext];
    }
}

+(NSArray*)getAllWithStatusRegisteredOrRequested {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:FRIENDS_TABLE_COLUMN_NAME_NAME ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@ = \"%d\" || %@ = \"%d\"", FRIENDS_TABLE_COLUMN_NAME_STATUS, STATUS_REGISTERED, FRIENDS_TABLE_COLUMN_NAME_STATUS, STATUS_REQUESTED]];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    return fetchedRecords;
}

+(NSArray*)getAllWithStatusUnregistered {
    return [self getAllWithStatus:@(STATUS_UNREGISTERED)];
}

@end
