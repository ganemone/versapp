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
            [selfInstance setConfessions:[[NSMutableArray alloc] initWithCapacity:100]];
        }
    }
    return selfInstance;
}

@end
