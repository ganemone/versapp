//
//  ConfessionsManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionsManager.h"

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
    return [_confessions count];
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

@end
