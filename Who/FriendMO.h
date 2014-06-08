//
//  FriendMO.h
//  Who
//
//  Created by Giancarlo Anemone on 3/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriendMO : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * searchedEmail;
@property (nonatomic, retain) NSString * searchedPhoneNumber;


@end
