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

@property NSMutableDictionary *confessions;
@property NSMutableArray *confessionIDValues;

+(instancetype)getInstance;

-(int)getNumberOfConfessions;

-(Confession*)getConfessionAtIndex:(int)index;

-(Confession*)getConfessionWithID:(NSString*)confessionID;

-(void)addConfession:(Confession*)confession;

@end
