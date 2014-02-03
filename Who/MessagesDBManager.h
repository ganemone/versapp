//
//  MessagesDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MessagesDBManager : NSObject

+(void)insert:(NSString*)messageBody groupID:(NSString*)groupID time:(NSString*)time senderID:(NSString*)senderID receiverID:(NSString*)receiverID;

+(void)insert:(NSString*)messageBody groupID:(NSString*)groupID time:(NSString*)time senderID:(NSString*)senderID receiverID:(NSString*)receiverID imageLink:(NSString*)imageLink;

+(NSArray*)getMessagesByChat:(NSString*)chatID;

@end
