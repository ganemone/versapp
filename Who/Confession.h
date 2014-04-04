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
@property CGFloat height;
@property CGRect cellFrame;
@property CGRect textViewFrame;
@property CGRect footerViewFrame;
@property CGRect chatButtonFrame;
@property CGRect favoriteButtonFrame;
//@property CGRect *chatLabel;
@property CGRect favoriteLabelFrame;
@property CGRect timestampLabelFrame;
@property CGRect deleteButtonFrame;

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

-(NSUInteger)getNumForLabel;

- (CGFloat)heightForConfession;

-(void)deleteConfession;

@end
