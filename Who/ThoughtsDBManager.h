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

@interface ThoughtsDBManager : NSObject

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites hasFavorited:(NSString *)hasFavorited inConversation:(NSString *)inConversation;

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites hasFavorited:(NSString *)hasFavorited inConversation:(NSString *)inConversation imageURL:(NSString *)imageURL;

@end
