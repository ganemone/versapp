//
//  FriendsDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FriendsDBManager : NSObject

+(void)insert:(NSString*)username name:(NSString*)name status:(NSNumber *)status;

+(NSArray*)getAll;

+(NSArray*)getAllWithStatus:(NSNumber*)status;

@end
