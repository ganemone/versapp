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

@implementation MessagesDBManager

+(void)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:[delegate managedObjectContext]];
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    
    NSError *error = NULL;
    [[delegate managedObjectContext] save:&error];
    if(error != NULL) {
        NSLog(@"Error Saving Data: %@", error);
    }
}

+(void)insert:(NSString *)messageBody groupID:(NSString *)groupID time:(NSString *)time senderID:(NSString *)senderID receiverID:(NSString *)receiverID imageLink:(NSString *)imageLink {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObject *message = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_MESSAGES inManagedObjectContext:[delegate managedObjectContext]];
    [message setValue:messageBody forKey:MESSAGE_PROPERTY_BODY];
    [message setValue:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
    [message setValue:time forKey:MESSAGE_PROPERTY_TIMESTAMP];
    [message setValue:senderID forKey:MESSAGE_PROPERTY_SENDER_ID];
    [message setValue:receiverID forKey:MESSAGE_PROPERTY_RECEIVER_ID];
    [message setValue:imageLink forKey:MESSAGE_PROPERTY_IMAGE_LINK];
    
    NSError *error = NULL;
    [[delegate managedObjectContext] save:&error];
    if(error != NULL) {
        NSLog(@"Error Saving Data: %@", error);
    }
}

+(NSArray *)getMessagesByChat:(NSString *)chatID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_FRIENDS inManagedObjectContext:[delegate managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ = %@)", MESSAGE_PROPERTY_GROUP_ID, chatID];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *fetchedRecords = [[delegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

@end
