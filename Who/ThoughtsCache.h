//
//  ThoughtsCache.h
//  Versapp
//
//  Created by Giancarlo Anemone on 8/3/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThoughtMO.h"
#import "Confession.h"

@interface ThoughtsCache : NSObject

typedef enum thoughtMethodTypes
{
    THOUGHTS_METHOD_YOU,
    THOUGHTS_METHOD_FRIENDS,
    THOUGHTS_METHOD_GLOBAL
} ThoughtMethod;

@property enum thoughtMethodTypes method;

- (id)initWithMethod:(enum thoughtMethodTypes)thoughtMethod;
-(int)getNumberOfConfessions;
-(Confession*)getConfessionAtIndex:(int)index;
-(Confession*)getConfessionWithID:(NSString*)confessionID;
-(NSUInteger)getIndexOfConfession:(NSString*)confessionID;
-(void)addConfession:(Confession*)confession;
-(void)updateConfession:(Confession*)confession;
-(void)sortConfessions;
-(void)clearConfessions;
-(void)deleteConfession:(NSString *)confessionID;
-(void)loadConfessions;
-(void)loadConfessionsSince:(NSString *)since;
-(NSString *)getSinceForThoughtRequest;
-(BOOL)hasCache;

@end
