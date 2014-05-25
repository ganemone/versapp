//
//  ConfessionsManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Confession.h"

@interface ConfessionsManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *confessions;
@property (strong, nonatomic) NSMutableArray *confessionIDValues;
@property (strong, nonatomic) Confession *pendingConfession;
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
-(void)clearConfessions;
-(void)deleteConfession:(NSString *)confessionID;
-(void)loadConfessionsWithMethod:(NSString *)method;
-(void)loadConfessionsWithMethod:(NSString *)method since:(NSString *)since;

@end
