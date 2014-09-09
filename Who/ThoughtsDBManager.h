//
//  ThoughtsDBManager.h
//  Versapp
//
//  Created by Riley Lundquist on 7/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ThoughtMO.h"
#import "Confession.h"

@interface ThoughtsDBManager : NSObject

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites hasFavorited:(BOOL)hasFavorited imageURL:(NSString *)imageURL;
+(ThoughtMO *)insertThoughtWithConfession:(Confession *)confession;
+(ThoughtMO *)updateThought:(ThoughtMO *)thought withConfession:(Confession *)confession;

+(ThoughtMO *)getThoughtWithID:(NSString *)confessionID;
+(ThoughtMO *)getThoughtWithBody:(NSString *)body;
+(BOOL)hasThoughtWithID:(NSString *)confessionID;

+(void)setInConversationNo:(NSString *)confessionID;
+(void)setInConversationYes:(NSString *)confessionID;
+(void)setHasFavoritedNo:(NSString *)confessionID;
+(void)setHasFavoritedYes:(NSString *)confessionID;


@end
