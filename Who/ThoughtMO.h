//
//  ThoughtMO.h
//  Versapp
//
//  Created by Riley Lundquist on 7/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ThoughtMO : NSManagedObject

@property (nonatomic, retain) NSString * confessionID;
@property (nonatomic, retain) NSString * posterJID;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * createdTimestamp;
@property (nonatomic, retain) NSString * degree;
@property (nonatomic, retain) NSNumber * numFavorites;
@property (nonatomic, retain) NSString * hasFavorited;
@property (nonatomic, retain) NSString * inConversation;

@end
