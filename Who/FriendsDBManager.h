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

+(void)insert:(NSString*)username name:(NSString*)name email:(NSString*)email status:(NSNumber *)status;

+(NSArray*)getAll;

+(NSArray*)getAllWithStatus:(NSNumber*)status;

+(FriendMO*)getUserWithJID:(NSString*)jid;

+(FriendMO*)getUserWithEmail:(NSString*)email;

+(BOOL)hasUserWithJID:(NSString*)jid;

+(BOOL)hasUserWithEmail:(NSString*)email;

+(BOOL)updateEntry:(NSString*)username name:(NSString*)name email:(NSString*)email status:(NSNumber *)status;

@end
