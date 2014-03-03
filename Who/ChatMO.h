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
@property (nonatomic, retain) NSString * has_new_message;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * user_defined_chat_name;
@property (nonatomic, retain) NSSet *messages;
@end

@interface ChatMO (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(MessageMO *)value;
- (void)removeMessagesObject:(MessageMO *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
