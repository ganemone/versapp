//
//  ChatMO.h
//  Who
//
//  Created by Giancarlo Anemone on 3/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageMO;

@interface ChatMO : NSManagedObject

@property (nonatomic, retain) NSString * chat_id;
@property (nonatomic, retain) NSString * chat_name;
@property (nonatomic, retain) NSString * chat_type;
@property (nonatomic, retain) NSString * has_new_message;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * user_defined_chat_name;
@property (nonatomic, retain) NSString * participant_string;
@property (nonatomic, retain) NSString * owner_id;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *participants;

-(NSString*)getLastMessage;

-(void)sendMUCMessageWithBody:(NSString *)messageText imageLink:(NSString*)imageLink;

-(void)sendOneToOneMessage:(NSString*)messageText imageLink:(NSString*)imageLink;

-(int)getNumberOfMessages;

-(void)addMessage:(MessageMO*)message;

-(void)updateMessage:(MessageMO*)message;

-(NSString*)getMessageTo;

+(NSString *)createGroupID;

@end
