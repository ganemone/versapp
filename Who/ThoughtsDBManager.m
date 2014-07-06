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

+(ThoughtMO *)insertThoughtWithID:(NSString *)confessionID posterJID:(NSString *)posterJID body:(NSString *)body timestamp:(NSString *)timestamp degree:(NSString *)degree favorites:(NSNumber *)favorites imageURL:(NSString *)imageURL {
    NSLog(@"Inserting Thought With Degree: %@", degree);
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    ThoughtMO *thought = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_THOUGHTS inManagedObjectContext:moc];
    [thought setValue:confessionID forKey:THOUGHTS_TABLE_COLUMN_NAME_CONFESSION_ID];
    [thought setValue:posterJID forKey:THOUGHTS_TABLE_COLUMN_NAME_POSTER_JID];
    [thought setValue:body forKey:THOUGHTS_TABLE_COLUMN_NAME_BODY];
    [thought setValue:timestamp forKey:THOUGHTS_TABLE_COLUMN_NAME_TIMESTAMP];
    [thought setValue:degree forKey:THOUGHTS_TABLE_COLUMN_NAME_DEGREE];
    [thought setValue:favorites forKey:THOUGHTS_TABLE_COLUMN_NAME_FAVORITES];
    //[thought setValue:hasFavorited forKey:THOUGHTS_TABLE_COLUMN_NAME_HAS_FAVORITED];
    //[thought setValue:inConversation forKey:THOUGHTS_TABLE_COLUMN_NAME_IN_CONVERSATION];
    [thought setValue:imageURL forKey:THOUGHTS_TABLE_COLUMN_NAME_IMAGE_URL];
    [delegate saveContext];
    
    return thought;
}

+(ThoughtMO *)getThoughtWithID:(NSString *)confessionID {
    ThoughtMO *thought = [[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", THOUGHTS_TABLE_COLUMN_NAME_CONFESSION_ID, confessionID]] firstObject];
    return thought;
}

+(ThoughtMO *)getThoughtWithBody:(NSString *)body {
    ThoughtMO *thought = [[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", THOUGHTS_TABLE_COLUMN_NAME_BODY, body]] firstObject];
    return thought;
}

+(BOOL)hasThoughtWithID:(NSString *)confessionID {
    return ([self getThoughtWithID:confessionID] != nil);
}

+(void)setInConversationNo:(NSString *)confessionID {
    ThoughtMO *thought = [self getThoughtWithID:confessionID];
    [thought setValue:@"NO" forKey:THOUGHTS_TABLE_COLUMN_NAME_IN_CONVERSATION];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(void)setInConversationYes:(NSString *)confessionID {
    ThoughtMO *thought = [self getThoughtWithID:confessionID];
    [thought setValue:@"YES" forKey:THOUGHTS_TABLE_COLUMN_NAME_IN_CONVERSATION];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(void)setHasFavoritedNo:(NSString *)confessionID {
    ThoughtMO *thought = [self getThoughtWithID:confessionID];
    [thought setValue:@"NO" forKey:THOUGHTS_TABLE_COLUMN_NAME_HAS_FAVORITED];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(void)setHasFavoritedYes:(NSString *)confessionID {
    ThoughtMO *thought = [self getThoughtWithID:confessionID];
    [thought setValue:@"YES" forKey:THOUGHTS_TABLE_COLUMN_NAME_HAS_FAVORITED];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    return [self makeFetchRequest:predicateString withMOC:moc];
}

+(NSArray *)makeFetchRequest:(NSString *)predicateString withMOC:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_THOUGHTS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = NULL;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

@end
