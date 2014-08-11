//
//  ConfessionsManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Confession.h"
#import "ThoughtsCache.h"

@interface ConfessionsManager : NSObject

@property (strong, nonatomic) ThoughtsCache * global;
@property (strong, nonatomic) ThoughtsCache * friends;
@property (strong, nonatomic) ThoughtsCache * you;

@property (strong, nonatomic) Confession *pendingConfession;
@property enum thoughtMethodTypes method;

@property BOOL shouldClearConfessions;

+(instancetype)getInstance;
-(int)getNumberOfConfessions;
-(Confession*)getConfessionAtIndex:(int)index;
-(Confession*)getConfessionWithID:(NSString*)confessionID;
-(NSUInteger)getIndexOfConfession:(NSString*)confessionID;
-(void)addConfession:(Confession*)confession;
-(void)updateConfession:(Confession*)confession;
-(void)updatePendingConfession:(NSString*)confessionID timestamp:(NSString*)timestamp;
-(void)sortConfessions;
-(void)deleteConfession:(NSString *)confessionID;
-(void)loadConfessions;
-(void)loadConfessionsSince:(NSString *)since;
-(NSString *)getSinceForThoughtRequest;
-(BOOL)hasCache;

@end
