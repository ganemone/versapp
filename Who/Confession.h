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
@property (strong, nonatomic) NSString *posterJID;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *createdTimestamp;
@property (strong, nonatomic) NSString *degree;
@property int numFavorites;
@property BOOL hasFavorited;

+(instancetype)create:(NSString*)body imageURL:(NSString*)imageURL;
+(instancetype)create:(NSString*)body posterJID:(NSString*)posterJID imageURL:(NSString*)imageURL confessionID:(NSString*)confessionID createdTimestamp:(NSString*)createdTimestamp degreeOfConnection:(NSString *)degree hasFavorited:(BOOL)hasFavorited numFavorites:(int)numFavorites;
- (BOOL)toggleFavorite;
- (void)encodeBody;
- (void)decodeBody;
- (BOOL)isFavoritedByConnectedUser;
- (BOOL)isPostedByConnectedUser;
- (NSString*)getTimePosted;
- (void)startChat;
- (NSString *)getTextForLabel;
- (NSUInteger)getNumForLabel;
- (void)deleteConfession;
- (UIImage *)imageForDegree;

@end
