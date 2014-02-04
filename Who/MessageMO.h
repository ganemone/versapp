//
//  MessageMO.h
//  Who
//
//  Created by Giancarlo Anemone on 2/3/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageMO : NSManagedObject

@property (nonatomic, retain) NSString * message_body;
@property (nonatomic, retain) NSString * sender_id;
@property (nonatomic, retain) NSString * receiver_id;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * group_id;
@property (nonatomic, retain) NSString * image_link;

@end
