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

+(FriendMO *)insert:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    FriendMO *friend = (email == nil) ? [self getUserWithJID:username] : [self getUserWithJID:username email:email];
    if (friend == nil) {
        NSLog(@"Inserting new friend");
        friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    } else {
        NSLog(@"Updating Friend");
    }
    if (username != nil && friend.username == nil) {
        [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
        NSLog(@"Setting Friend MO Username: %@", username);
    }
    if (name != nil) {
        [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
        NSLog(@"Setting Friend MO Name: %@", name);
    }
    if (email != nil) {
        [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
        NSLog(@"Setting Friend MO Email: %@", email);
    }
    if (status != nil) {
        [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
        NSLog(@"Setting %@'s MO Status: %@", friend.name, status);
    }
    if (searchedPhoneNumber != nil) {
        [friend setValue:searchedPhoneNumber forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
        //NSLog(@"Setting Friend MO Searched Phone: %@", searchedPhoneNumber);
    }
    if (searchedEmail != nil) {
        [friend setValue:searchedEmail forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        //NSLog(@"Setting Friend MO Searched Email: %@", searchedEmail);
    }
    
    //NSLog(@"Friend: %@", [friend description]);
    [delegate saveContext];
    return friend;
}

+ (void)updateFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSNumber *status = [friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    if ([status isEqualToNumber:[NSNumber numberWithInt:STATUS_REGISTERED]]) {
        [self updateRegisteredFriendAfterUserSearch:friend withContext:moc];
    } else {
        [self updateUnregisteredFriendAfterUserSearch:friend withContext:moc];
    }
}

+ (void)updateRegisteredFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSString *username = [friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [friend objectForKey:VCARD_TAG_FIRST_NAME], [friend objectForKey:VCARD_TAG_LAST_NAME]];
    NSLog(@"Updating Registered Friend After User Search %@", fullName);
    FriendMO *friendMO = [self getUserWithJID:username moc:moc];
    if (friendMO == nil) {
        friendMO = [self insertWithMOC:moc
                              username:username
                                  name:fullName
                                 email:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]
                                status:[NSNumber numberWithInt:STATUS_REGISTERED]
                   searchedPhoneNumber:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER]
                         searchedEmail:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]];
    } else {
        [friendMO setValue:username forKeyPath:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
        [friendMO setValue:fullName forKeyPath:FRIENDS_TABLE_COLUMN_NAME_NAME];
        [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        [friendMO setValue:[NSNumber numberWithInt:STATUS_REGISTERED] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_STATUS];
        [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
        [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
    }
}

+ (void)updateUnregisteredFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc {
    NSString *searchedPhoneNumber = [friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
    NSString *searchedEmail = [friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", [friend objectForKey:VCARD_TAG_FIRST_NAME], [friend objectForKey:VCARD_TAG_LAST_NAME]];
    NSLog(@"Updating Unregistered Friend After User Search %@", fullName);
    NSArray *friends;
    if (searchedPhoneNumber != nil && searchedPhoneNumber.length > 0) {
        friends = [self getUserWithSearchedPhoneNumber:searchedPhoneNumber withMOC:moc];
    } else {
        friends = [self getUserWithSearchedEmail:searchedEmail withMOC:moc];
    }
    if (friends.count > 0) {
        for (FriendMO *friendMO in friends) {
            [friendMO setValue:fullName forKeyPath:FRIENDS_TABLE_COLUMN_NAME_NAME];
            [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
            [friendMO setValue:[NSNumber numberWithInt:STATUS_UNREGISTERED] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_STATUS];
            [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
            [friendMO setValue:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL] forKeyPath:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        }
    } else {
        [self insertWithMOC:moc
                   username:nil
                       name:fullName
                      email:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]
                     status:[NSNumber numberWithInt:STATUS_UNREGISTERED]
        searchedPhoneNumber:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER]
              searchedEmail:[friend objectForKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL]];
    }
}

+ (NSArray *)getUserWithSearchedPhoneNumber:(NSString *)phoneNumber withMOC:(NSManagedObjectContext *)moc {
    return [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER, phoneNumber] moc:moc];
}

+ (NSArray *)getUserWithSearchedEmail:(NSString *)email withMOC:(NSManagedObjectContext *)moc {
    return [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL, email] moc:moc];
}

+ (FriendMO *)insertWithMOC:(NSManagedObjectContext *)moc username:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail {
    FriendMO *friend = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    if (username != nil) {
        [friend setValue:username forKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
        NSLog(@"Setting Friend MO Username: %@", username);
    }
    if (name != nil) {
        [friend setValue:name forKey:FRIENDS_TABLE_COLUMN_NAME_NAME];
        NSLog(@"Setting Friend MO Name: %@", name);
    }
    if (email != nil) {
        [friend setValue:email forKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL];
        NSLog(@"Setting Friend MO Email: %@", email);
    }
    if (status != nil) {
        [friend setValue:status forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
        NSLog(@"Setting %@'s MO Status: %@", username, status);
    }
    if (searchedPhoneNumber != nil) {
        [friend setValue:searchedPhoneNumber forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_PHONE_NUMBER];
        NSLog(@"Setting Friend MO Searched Phone: %@", searchedPhoneNumber);
    }
    if (searchedEmail != nil) {
        [friend setValue:searchedEmail forKey:FRIENDS_TABLE_COLUMN_NAME_SEARCHED_EMAIL];
        NSLog(@"Setting Friend MO Searched Email: %@", searchedEmail);
    }
    return friend;
    //[delegate saveContextWithMOC:moc];
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
        NSLog(@"Found Item!");
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithJID:(NSString *)jid {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithEmail:(NSString *)email moc:(NSManagedObjectContext *)moc  {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_EMAIL, email] moc:moc];
    if(fetchedData.count > 0) {
        NSLog(@"Found Item!");
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithJID:(NSString *)jid moc:(NSManagedObjectContext *)moc  {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid] moc:moc];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithJID:(NSString *)jid email:(NSString *)email {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" OR %@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid, FRIENDS_TABLE_COLUMN_NAME_EMAIL, email]];
    if(fetchedData.count > 0) {
        return [fetchedData firstObject];
    }
    return nil;
}

+(FriendMO *)getUserWithJID:(NSString *)jid email:(NSString *)email moc:(NSManagedObjectContext *)moc {
    NSArray *fetchedData = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" OR %@ = \"%@\"", FRIENDS_TABLE_COLUMN_NAME_USERNAME, jid, FRIENDS_TABLE_COLUMN_NAME_EMAIL, email] moc:moc];
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

+(NSArray*)makeFetchRequest:(NSString*)predicateString moc:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    return [self makeFetchRequest:predicateString moc:moc];
}

+(NSArray*)makeFetchRequestWithPredicate:(NSPredicate*)predicate {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
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

+(BOOL)updateUserSetStatusRequested:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_REQUESTED]];
}

+(BOOL)updateUserSetStatusInvited:(NSString *)username {
    return [self updateUserStatus:username status:[NSNumber numberWithInt:STATUS_INVITED]];
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

+(NSArray*)getAllWithStatusRegisteredOrRequested {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
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

+(NSArray*)getAllWithStatusRejected {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_REJECTED]];
}

+(NSArray*)getAllWithStatusUnregistered {
    return [self getAllWithStatus:[NSNumber numberWithInt:STATUS_UNREGISTERED]];
}

@end
