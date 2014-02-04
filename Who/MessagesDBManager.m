//
//  MessagesDBManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//
#import "AppDelegate.h"
#import "MessagesDBManager.h"
#import "Constants.h"
#import "Message.h"
#import "MessageMO.h"
#import "ConnectionProvider.h"

@implementation MessagesDBManager

+(void)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    NSLog(@"Inserting Message: %@", [message description]);
    NSError *error = NULL;
    if(![moc save:&error]) {
        NSLog(@"Error Saving Data: %@", error);
    }
}

+(void)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID imageLink:(NSString *)imageLink {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    [message setValue:imageLink forKey:MESSAGE_PROPERTY_IMAGE_LINK];
    
    NSError *error = NULL;
    if(![moc save:&error]) {
        NSLog(@"Error Saving Data: %@", error);
    }
}

+(NSArray *)getMessagesByChat:(NSString *)chatID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ = %@)", MESSAGE_PROPERTY_GROUP_ID, chatID];
    //[fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Fetched Record Length: %lu", (unsigned long)fetchedRecords.count);
    return fetchedRecords;
}

+(NSMutableArray *)getMessageObjectsForMUC:(NSString *)chatID {
    NSArray *fetchedRecords = [self getMessagesByChat:chatID];
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:fetchedRecords.count];
    MessageMO *dbmessage;
    for (int i = 0; i < fetchedRecords.count; i++) {
        dbmessage = [fetchedRecords objectAtIndex:i];
        [messages addObject:[Message createForMUC:dbmessage.message_body sender:dbmessage.sender_id chatID:dbmessage.group_id timestamp:dbmessage.time]];
    }
    return messages;
}

+(NSMutableArray *)getMessageObjectsForOneToOneChat:(NSString *)chatID {
    NSArray *fetchedRecords = [self getMessagesByChat:chatID];
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:fetchedRecords.count];
    MessageMO *dbmessage;
    for (int i = 0; i < fetchedRecords.count; i++) {
        dbmessage = [fetchedRecords objectAtIndex:i];
        [messages addObject:[Message createForOneToOne:dbmessage.message_body sender:dbmessage.sender_id chatID:dbmessage.group_id messageTo:dbmessage.receiver_id timestamp:dbmessage.time]];
    }
    return messages;
}

@end
