//
//  ConfessionsManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionsManager.h"
#import "AppDelegate.h"

static ConfessionsManager *selfInstance;

@implementation ConfessionsManager

+ (instancetype) getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            [selfInstance setConfessions:[[NSMutableDictionary alloc] initWithCapacity:100]];
            [selfInstance setConfessionIDValues:[[NSMutableArray alloc] initWithCapacity:100]];
        }
    }
    return selfInstance;
}

-(int)getNumberOfConfessions {
    return (int)[_confessions count];
}

-(Confession *)getConfessionAtIndex:(int)index {
    return [_confessions objectForKey:[_confessionIDValues objectAtIndex:index]];
}

-(Confession *)getConfessionWithID:(NSString *)confessionID {
    return [_confessions objectForKey:confessionID];
}

-(void)addConfession:(Confession *)confession {
    [self.confessions setObject:confession forKey:confession.confessionID];
    [self.confessionIDValues addObject:confession.confessionID];
}

-(void)updateConfession:(Confession *)confession {
    [self.confessions setObject:confession forKey:confession.confessionID];
}

-(void)updatePendingConfession:(NSString*)confessionID timestamp:(NSString*)timestamp {
    [_pendingConfession setConfessionID:confessionID];
    [_pendingConfession setCreatedTimestamp:timestamp];
    [_pendingConfession decodeBody];
    [self addConfession:_pendingConfession];
    [self setPendingConfession:nil];
}

-(void)sortConfessions {
    _confessionIDValues = [NSMutableArray arrayWithArray:[_confessionIDValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Confession *confession1 = [_confessions objectForKey:obj1];
        Confession *confession2 = [_confessions objectForKey:obj2];
        return [[confession2 createdTimestamp] compare:[confession1 createdTimestamp]];
    }]];
}

-(void)clearConfessions {
    [_confessionIDValues removeAllObjects];
    [_confessions removeAllObjects];
}

-(void)deleteConfession:(NSString *)confessionID {
    [_confessions removeObjectForKey:confessionID];
}

-(NSUInteger)getIndexOfConfession:(NSString *)confessionID {
    return [_confessionIDValues indexOfObject:confessionID];
}

@end
