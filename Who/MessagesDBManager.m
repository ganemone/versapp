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
#import "MessageMO.h"
#import "ConnectionProvider.h"

@implementation MessagesDBManager

+(MessageMO*)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    MessageMO *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    NSLog(@"Inserting Message: %@", [message description]);
    [delegate saveContext];
    
    return message;
}

+(MessageMO*)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID imageLink:(NSString *)imageLink {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    MessageMO *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    [message setValue:imageLink forKey:MESSAGE_PROPERTY_IMAGE_LINK];
    NSLog(@"Inserting Message: %@", [message description]);
    [delegate saveContext];
    
    return message;
}

+(void)updateMessageWithGroupID:(NSString *)groupID time:(NSString *)time {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:MESSAGE_PROPERTY_TIMESTAMP ascending:NO];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = \"%@\" && %@ = \"%@\"", MESSAGE_PROPERTY_GROUP_ID, groupID, MESSAGE_PROPERTY_SENDER_ID, [ConnectionProvider getUser]]];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setPredicate:predicate];
    NSError* error;
    NSArray *fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
    MessageMO *itemToUpdate = [fetchedItems firstObject];
    if (itemToUpdate != nil) {
        [itemToUpdate setTime:time];
        [delegate saveContext];
    }
}

+(NSMutableArray *)getMessagesByChat:(NSString *)chatID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = \"%@\"", MESSAGE_PROPERTY_GROUP_ID, chatID]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:MESSAGE_PROPERTY_TIMESTAMP ascending:YES];
    [fetchRequest setFetchLimit:100];
    [fetchRequest setPredicate:predicate];
    
    [fetchRequest setSortDescriptors:@[sort]];
    NSError* error;
    NSArray *fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
    return [NSMutableArray arrayWithArray:fetchedItems];
}

+(NSString*)getLastMessageForChatWithID:(NSString*)chatID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:MESSAGE_PROPERTY_TIMESTAMP ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = \"%@\"", MESSAGE_PROPERTY_GROUP_ID, chatID]];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
    return [[fetchedItems firstObject] message_body];
}

+(NSString*)getTimeForHistory:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:MESSAGE_PROPERTY_TIMESTAMP ascending:NO];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    NSError* error;
    NSArray *fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
    MessageMO *message = [fetchedItems firstObject];
    NSLog(@"Using this message for time... %@", [message description]);
    if ([fetchedItems count] > 0) {
        NSTimeInterval interval= [[[fetchedItems firstObject] time] doubleValue] + 1;
        NSDate *gregDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *utcStringDate =[formatter stringFromDate:gregDate];
        return utcStringDate;
    } else {
        return @"1970-01-01T00:00:00Z";
    }
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    return [self makeFetchRequestWithPredicate:[NSPredicate predicateWithFormat:predicateString]];
}

+(NSArray*)makeFetchRequestWithPredicate:(NSPredicate*)predicate {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(void)deleteMessagesFromChatWithID:(NSString *)chatID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = \"%@\"", MESSAGE_PROPERTY_GROUP_ID, chatID]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:MESSAGE_PROPERTY_TIMESTAMP ascending:YES];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sort]];
    NSError* error;
    NSArray *fetchedItems = [moc executeFetchRequest:fetchRequest error:&error];
    for (MessageMO *message in fetchedItems) {
        [moc deleteObject:message];
    }
    [delegate saveContext];
}

@end
