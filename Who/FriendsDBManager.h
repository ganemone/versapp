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

+(void)insert:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail;

+ (void)insertWithMOC:(NSManagedObjectContext *)moc username:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail;

+ (void)updateFriendAfterSearch:(NSString *)username name:(NSString *)name email:(NSString*)email status:(NSNumber *)status searchedPhoneNumber:(NSString*)searchedPhoneNumber searchedEmail:(NSString*)searchedEmail;

+ (FriendMO *)getUserWithJIDS:(NSArray *)phoneNumbers searchedEmails:(NSArray *)emails;

+(NSArray*)getAll;

+(NSArray*)getAllWithStatus:(NSNumber*)status;

+(FriendMO*)getUserWithJID:(NSString*)jid;

+(FriendMO*)getUserWithEmail:(NSString*)email;

+(FriendMO *)getUserWithJID:(NSString *)jid moc:(NSManagedObjectContext *)moc;

+(FriendMO*)getUserWithEmail:(NSString*)email moc:(NSManagedObjectContext *)moc;

+(BOOL)hasUserWithJID:(NSString*)jid;

+(BOOL)hasUserWithEmail:(NSString*)email;

+(BOOL)updateEntry:(NSString*)username name:(NSString*)name email:(NSString*)email status:(NSNumber *)status;

+(BOOL)updateUserSetStatusRegistered:(NSString*)username;

+(BOOL)updateUserSetStatusFriends:(NSString*)username;

+(BOOL)updateUserSetStatusPending:(NSString*)username;

+(BOOL)updateUserSetStatusRejected:(NSString*)username;

+(BOOL)updateUserSetStatusUnregistered:(NSString*)username;

+(BOOL)updateUserSetStatusRequested:(NSString *)username;

+(BOOL)updateUserSetStatusInvited:(NSString *)username;

+(NSArray*)getAllWithStatusRegistered;

+(NSArray*)getAllWithStatusFriends;

+(NSArray*)getAllWithStatusPending;

+(NSArray*)getAllWithStatusRejected;

+(NSArray*)getAllWithStatusUnregistered;

+(NSArray*)getAllWithStatusRegisteredOrRequested;

@end
