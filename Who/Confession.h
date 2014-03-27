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
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *footerView;
@property (strong, nonatomic) UIButton *chatButton;
@property (strong, nonatomic) UIButton *favoriteButton;
@property (strong, nonatomic) UILabel *chatLabel;
@property (strong, nonatomic) UILabel *favoriteLabel;
@property (strong, nonatomic) UILabel *timestampLabel;

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
