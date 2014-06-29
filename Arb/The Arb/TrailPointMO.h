//
//  TrailPointMO.h
//  The Arb
//
//  Created by Riley Lundquist on 6/25/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrailPointMO : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * trail_id;
@property (nonatomic, retain) NSNumber * point_id;

@end
