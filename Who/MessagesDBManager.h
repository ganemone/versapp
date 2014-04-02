//
//  MessagesDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageMO.h"

@interface MessagesDBManager : NSObject

+(MessageMO*)insert:(NSString*)messageBody groupID:(NSString*)groupID time:(NSString*)time senderID:(NSString*)senderID receiverID:(NSString*)receiverID;

+(MessageMO*)insert:(NSString*)messageBody groupID:(NSString*)groupID time:(NSString*)time senderID:(NSString*)senderID receiverID:(NSString*)receiverID imageLink:(NSString*)imageLink;

+(void)updateMessageWithGroupID:(NSString *)groupID time:(NSString *)time;

+(NSMutableArray*)getMessagesByChat:(NSString*)chatID;

+(NSString*)getTimeForHistory:(NSManagedObjectContext *)moc;

+(void)deleteMessagesFromChatWithID:(NSString *)chatID;

@end
