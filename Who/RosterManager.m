//
//  RosterManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/7/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "RosterManager.h"
#import "UserProfile.h"

@interface RosterManager()

@property(strong, nonatomic) NSMutableDictionary *rosterItems;

@end

@implementation RosterManager

static RosterManager *selfInstance;

+(RosterManager *)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.rosterItems = [[NSMutableDictionary alloc] init];
        }
    }
    return selfInstance;
}

-(void)addRosterItem:(UserProfile*)user {
    [self.rosterItems setObject:user forKey:user.jid];
}

-(UserProfile*)getRosterItem:(NSString*)jid {
    return [self.rosterItems objectForKey:jid];
}


@end
