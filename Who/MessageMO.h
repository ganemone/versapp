//
//  Messages.h
//  Who
//
//  Created by Lauren McGlinn on 2/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MessageMO : NSManagedObject

@property (strong, nonatomic) NSString * time;
@property (strong, nonatomic) NSString * sender_id;
@property (strong, nonatomic) NSString * image_link;
@property (strong, nonatomic) NSString * receiver_id;
@property (strong, nonatomic) NSString * message_body;
@property (strong, nonatomic) NSString * group_id;

@end
