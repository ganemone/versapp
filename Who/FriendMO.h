//
//  FriendMO.h
//  Who
//
//  Created by Giancarlo Anemone on 2/3/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriendMO : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;

@end
