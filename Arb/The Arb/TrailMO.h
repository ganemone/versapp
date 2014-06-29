//
//  TrailMO.h
//  The Arb
//
//  Created by Riley Lundquist on 6/25/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TrailMO : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * trail_id;

@end
