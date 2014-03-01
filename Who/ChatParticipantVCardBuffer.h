//
//  ChatParticipantVCardBuffer.h
//  Who
//
//  Created by Giancarlo Anemone on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "UserProfile.h"

@interface ChatParticipantVCardBuffer : NSObject

@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSMutableArray *pending;
@property (strong, nonatomic) NSMutableArray *accepted;

+(id)getInstance;

-(void)addVCard:(UserProfile*)vcard;

-(UserProfile*)getVCard:(NSString*)username;

-(NSString*)getName:(NSString*)username;

-(BOOL)hasVCard:(NSString*)username;

-(BOOL)isFriendsWithUser:(NSString *)username;

-(BOOL)isPendingFriendWithUser:(NSString*)username;

-(void)updateUserProfile:(NSString*)jid firstName:(NSString*)firstName lastName:(NSString*)lastName nickname:(NSString*)nickname email:(NSString*)email;

-(NSArray*)getAcceptedUserProfiles;

-(void)addPendingFriend:(NSString*)username;

@end
