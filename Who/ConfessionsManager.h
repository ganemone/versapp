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

@property NSMutableArray *confessions;

+(instancetype)getInstance;

@end
