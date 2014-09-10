//
//  FriendsDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FriendMO.h"

@interface FriendsDBManager : NSObject

+(FriendMO *)insert:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail uid:(NSNumber *)uid;

+ (BOOL)hasEnoughFriends;

+ (BOOL)insertWithMOC:(NSManagedObjectContext *)moc username:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail uid:(NSNumber *)uid;

+ (NSArray *)getUserWithSearchedPhoneNumber:(NSString *)phoneNumber withMOC:(NSManagedObjectContext *)moc;

+ (NSArray *)getUserWithSearchedEmail:(NSString *)email withMOC:(NSManagedObjectContext *)moc;

+ (void)updateFriendAfterUserSearch:(NSDictionary *)friend withContext:(NSManagedObjectContext *)moc;

//+(NSArray*)getAll;

+(NSArray*)getAllWithStatus:(NSNumber*)status;

+(FriendMO*)getUserWithJID:(NSString*)jid;

+(FriendMO*)getUserWithEmail:(NSString*)email;

+(FriendMO *)getUserWithJID:(NSString *)jid moc:(NSManagedObjectContext *)moc;

//+(FriendMO*)getUserWithEmail:(NSString*)email moc:(NSManagedObjectContext *)moc;

+(BOOL)hasUserWithJID:(NSString*)jid;

//+(BOOL)hasUserWithEmail:(NSString*)email;

+(BOOL)updateEntry:(NSString*)username name:(NSString*)name email:(NSString*)email status:(NSNumber *)status;

+(BOOL)updateUserSetStatusFriends:(NSString*)username;

+(BOOL)updateUserSetStatusRejected:(NSString*)username;

+(BOOL)updateUserSetStatusRequested:(NSString *)username;

+(BOOL)updateUserSetStatusInvited:(NSString *)username;

//+(NSArray*)getAllWithStatusRegistered;

+ (void)deleteUserWithUsername:(NSString *)username;

+(NSArray*)getAllWithStatusFriends;

+(NSArray*)getAllWithStatusPending;

+(NSArray*)getAllWithStatusUnregistered;

+(NSArray*)getAllWithStatusRegisteredOrRequested;

@end
