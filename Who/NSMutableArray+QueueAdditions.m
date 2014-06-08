//
//  NSMutableArray+QueueAdditions.m
//  Versapp
//
//  Created by Giancarlo Anemone on 5/23/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NSMutableArray+QueueAdditions.h"

@implementation NSMutableArray (QueueAdditions)

// Queues are first-in-first-out, so we remove objects from the head
- (id) dequeue {
    // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}

@end
