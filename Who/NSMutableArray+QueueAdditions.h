//
//  NSMutableArray+QueueAdditions.h
//  Versapp
//
//  Created by Giancarlo Anemone on 5/23/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

- (id) dequeue;
- (void) enqueue:(id)obj;

@end
