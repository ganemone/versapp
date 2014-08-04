//
//  ConfessionsManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionsManager.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "Base64.h"
#import "FriendsDBManager.h"
#import "ThoughtsDBManager.h"
#import "ThoughtsCache.h"

static ConfessionsManager *selfInstance;

@implementation ConfessionsManager

+ (instancetype) getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            [selfInstance setMethod:THOUGHTS_METHOD_GLOBAL];
            [selfInstance setFriends:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_FRIENDS]];
            [selfInstance setGlobal:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_GLOBAL]];
            [selfInstance setYou:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_YOU]];
        }
    }
    return selfInstance;
}

-(ThoughtsCache *)getCurrentCache {
    switch (self.method) {
        case THOUGHTS_METHOD_FRIENDS: return _friends;
        case THOUGHTS_METHOD_GLOBAL: return _global;
        default: return _you;
    }
}

-(int)getNumberOfConfessions {
    return [[self getCurrentCache] getNumberOfConfessions];
}

-(Confession *)getConfessionAtIndex:(int)index {
    return [[self getCurrentCache] getConfessionAtIndex:index];
}

-(Confession *)getConfessionWithID:(NSString *)confessionID {
    return [[self getCurrentCache] getConfessionWithID:confessionID];
}

-(NSString *)getSinceForThoughtRequest {
    return [[self getCurrentCache] getSinceForThoughtRequest];
}

-(void)addConfession:(Confession *)confession {
    [[self getCurrentCache] addConfession:confession];
}

-(void)updateConfession:(Confession *)confession {
    [[self getCurrentCache] updateConfession:confession];
}

-(void)updatePendingConfession:(NSString*)confessionID timestamp:(NSString*)timestamp {
    [_pendingConfession setConfessionID:confessionID];
    [_pendingConfession setCreatedTimestamp:timestamp];
    [_pendingConfession decodeBody];
    [self addConfession:_pendingConfession];
    
    [ThoughtsDBManager insertThoughtWithID:confessionID posterJID:_pendingConfession.posterJID body:_pendingConfession.body timestamp:_pendingConfession.createdTimestamp degree:_pendingConfession.degree favorites:[NSNumber numberWithInt:_pendingConfession.numFavorites] hasFavorited:NO imageURL:_pendingConfession.imageURL];
    [ThoughtsDBManager setHasFavoritedNo:confessionID];
    [ThoughtsDBManager setInConversationNo:confessionID];
    
    [self setPendingConfession:nil];
}

-(void)sortConfessions {
    [[self getCurrentCache] sortConfessions];
}

-(void)deleteConfession:(NSString *)confessionID {
    [[self getCurrentCache] deleteConfession:confessionID];
}

-(NSUInteger)getIndexOfConfession:(NSString *)confessionID {
    return [[self getCurrentCache] getIndexOfConfession:confessionID];
}

-(void)loadConfessions {
    NSLog(@"Confessions Manager - Loading Confessions");
    [[self getCurrentCache] loadConfessions];
}

-(void)loadConfessionsSince:(NSString *)since {
    NSLog(@"Confessions Manager - Loading Confessions Since: %@", since);
    [[self getCurrentCache] loadConfessionsSince:since];
}

-(BOOL)hasCache {
    return [[self getCurrentCache] hasCache];
}

@end
