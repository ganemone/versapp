//
//  ThoughtsDBManager.m
//  Versapp
//
//  Created by Riley Lundquist on 7/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtsDBManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation ThoughtsDBManager

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites hasFavorited:(NSString *)hasFavorited inConversation:(NSString *)inConversation {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    ThoughtMO *thought = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_THOUGHTS inManagedObjectContext:moc];
    [thought setValue:confessionID forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_CONFESSION_ID];
    [thought setValue:posterJID forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_POSTER_JID];
    [thought setValue:body forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_BODY];
    [thought setValue:timestamp forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_TIMESTAMP];
    [thought setValue:degree forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_DEGREE];
    [thought setValue:favorites forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_FAVORITES];
    [thought setValue:hasFavorited forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_HAS_FAVORITED];
    [thought setValue:inConversation forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_IN_CONVERSATION];
    [delegate saveContext];
    
    return thought;
}

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites hasFavorited:(NSString *)hasFavorited inConversation:(NSString *)inConversation imageURL:(NSString *)imageURL {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    ThoughtMO *thought = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_THOUGHTS inManagedObjectContext:moc];
    [thought setValue:confessionID forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_CONFESSION_ID];
    [thought setValue:posterJID forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_POSTER_JID];
    [thought setValue:body forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_BODY];
    [thought setValue:timestamp forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_TIMESTAMP];
    [thought setValue:degree forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_DEGREE];
    [thought setValue:favorites forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_FAVORITES];
    [thought setValue:hasFavorited forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_HAS_FAVORITED];
    [thought setValue:inConversation forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_IN_CONVERSATION];
    [thought setValue:imageURL forKeyPath:THOUGHTS_TABLE_COLUMN_NAME_IMAGE_URL];
    [delegate saveContext];
    
    return thought;
}

@end
