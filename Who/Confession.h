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
@property (strong, nonatomic) NSMutableArray *favoritedUsers;
@property CGRect cellFrame;
@property CGRect textFrame;
@property CGRect footerFrame;
@property CGRect chatButtonFrame;
@property CGRect chatLabelFrame;
@property CGRect favoriteButtonFrame;
@property CGRect favoriteLabelFrame;
@property CGRect timestampLabelFrame;
@property BOOL hasCalculatedFrames;

+(instancetype)create:(NSString*)body imageURL:(NSString*)imageURL;

+(instancetype)create:(NSString*)body posterJID:(NSString*)posterJID imageURL:(NSString*)imageURL confessionID:(NSString*)confessionID createdTimestamp:(NSString*)createdTimestamp favoritedUsers:(NSMutableArray*)favoritedUsers;

-(void)calculateFramesForTableViewCell:(CGSize)contentSize;
    
- (BOOL)toggleFavorite;

- (void)encodeBody;

- (void)decodeBody;

- (BOOL)isFavoritedByConnectedUser;

- (BOOL)isPostedByConnectedUser;

- (NSString*)getTimePosted;

- (void)startChat;

-(NSString *)getTextForLabel;

- (CGFloat)heightForConfession;

@end
