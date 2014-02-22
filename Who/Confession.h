//
//  Confession.h
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Confession : NSObject

@property (strong, nonatomic) NSString *confessionID;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *createdTimestamp;
@property (strong, nonatomic) NSMutableArray *favoritedUsers;

+(instancetype)create:(NSString*)body imageURL:(NSString*)imageURL;

+(instancetype)create:(NSString*)body imageURL:(NSString*)imageURL confessionID:(NSString*)confessionID createdTimestamp:(NSString*)createdTimestamp favoritedUsers:(NSMutableArray*)favoritedUsers;

- (void)toggleFavorite;

- (void)encodeBody;

- (void)decodeBody;


@end
