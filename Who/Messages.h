//
//  Messages.h
//  Who
//
//  Created by Lauren McGlinn on 2/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Messages : NSManagedObject

@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * sender_id;
@property (nonatomic, retain) NSString * image_link;
@property (nonatomic, retain) NSString * reciever_id;
@property (nonatomic, retain) NSString * message_body;
@property (nonatomic, retain) NSString * group_id;

@end
