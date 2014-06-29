//
//  TrailDBManager.h
//  The Arb
//
//  Created by Riley Lundquist on 6/25/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TrailMO.h"
#import "TrailPointMO.h"
#import "AppDelegate.h"

@interface TrailDBManager : NSObject

+(TrailMO *)insert:(NSString *)name color:(NSNumber *)color trail_id:(NSNumber *)trail_id;

+(TrailMO *)getTrailWithID:(NSNumber *)trail_id;
+(TrailMO *)getTrailWithName:(NSString *)name;

+(TrailPointMO *)insert:(NSNumber *)point_id trail_id:(NSNumber *)trail_id latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude;

+(TrailPointMO *)getTrailPointWithID:(NSNumber *)point_id;
+(NSArray *)getAllPointsForTrail:(NSNumber *)trail_id;
+(NSArray *)getAllPointsForTrailWithName:(NSString *)name;

@end
