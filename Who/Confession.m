//
//  Confession.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Confession.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ChatDBManager.h"
#import "Constants.h"
#import "StyleManager.h"
#import "ConfessionsManager.h"

@implementation Confession

+(instancetype)create:(NSString *)body imageURL:(NSString *)imageURL {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance setImageURL:imageURL];
    [instance setFavoritedUsers:[[NSMutableArray alloc] init]];
    [instance setHasCalculatedFrames:NO];
    return instance;
}

+(instancetype)create:(NSString *)body posterJID:(NSString *)posterJID imageURL:(NSString *)imageURL confessionID:(NSString *)confessionID createdTimestamp:(NSString *)createdTimestamp favoritedUsers:(NSMutableArray *)favoritedUsers {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance setPosterJID:posterJID];
    [instance setImageURL:imageURL];
    [instance setConfessionID:confessionID];
    [instance setCreatedTimestamp:createdTimestamp];
    [instance setFavoritedUsers:favoritedUsers];
    [instance setHasCalculatedFrames:NO];
    return instance;
}

-(void)calculateFramesForTableViewCell:(CGSize)contentSize {
    CGFloat cellX = 8.0f;
    CGFloat cellY = 0.0f;
    CGFloat cellHeight = [self heightForConfession];
    CGFloat textHeight = cellHeight - 50;
    _cellFrame = CGRectMake(cellX, cellY, contentSize.width - 2*cellX, cellHeight);
    _textViewFrame = CGRectMake(cellX, cellY, contentSize.width - 2*cellX, textHeight);
    _footerViewFrame = CGRectMake(cellX, textHeight, contentSize.width - 2*cellX, _cellFrame.size.width * 0.1176);
    _timestampLabelFrame = CGRectMake(cellX, textHeight - 15.0f, contentSize.width - 25.0f, 15.0f);
    // Configuring Chat Buttons
    CGFloat iconSize = 25.0f, paddingSmall = 5.0f, chatWidth = 505.0f/(201.0f/iconSize), favWidth = 795.0f/(196.0f/iconSize), deleteWidth = 550.0f/(188.0f/iconSize);
    
    _chatButtonFrame = CGRectMake(cellX + paddingSmall, textHeight + paddingSmall, chatWidth, iconSize);
    //_chatLabel = [[UILabel alloc] initWithFrame:chatLabelFrame];
    
    // Configure Favorites
    //CGRect favoriteButtonFrame = CGRectMake(contentSize.width - iconSize - cellX - 2 * paddingSmall, textHeight + paddingSmall, favWidth, iconSize);
    
    _favoriteButtonFrame = CGRectMake(contentSize.width - cellX - paddingSmall - favWidth, textHeight + paddingSmall, favWidth, iconSize);
    _favoriteLabelFrame = CGRectMake(_favoriteButtonFrame.origin.x - 25, _favoriteButtonFrame.origin.y + 2, 20, 20);//CGRectMake(contentSize.width / 2, textHeight + paddingSmall - 1.0f, contentSize.width / 2 - cellX - 2*paddingSmall - favWidth, iconSize);
    _deleteButtonFrame = CGRectMake(cellX + paddingSmall, textHeight + paddingSmall, deleteWidth, iconSize);
    _hasCalculatedFrames = YES;
}

- (CGFloat)heightForConfession {
    if (_height > 0.0f) {
        return _height;
    }
    UIFont *cellFont = [StyleManager getFontStyleBoldSizeXL];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [_body boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    _height = textRect.size.height;
    return _height;
    //_height = MAX(textRect.size.height + 80.0f, 121.0f);
    //return _height;
}

- (CGFloat)heightForConfessionWithFont:(UIFont *)cellFont {
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [_body boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    _height = textRect.size.height;
    return _height;
}

-(void)encodeBody {
    [self setBody: [self urlencode:_body]];
}

-(void)decodeBody {
    NSString *newBody = [[_body stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self setBody:newBody];
}

- (NSString *)urlencode:(NSString*)stringToEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[stringToEncode UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(BOOL)toggleFavorite {
    NSInteger selfIndex;
    NSString *jid = [NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
    if ((selfIndex = [_favoritedUsers indexOfObject:jid]) != NSNotFound) {
        [_favoritedUsers removeObjectAtIndex:selfIndex];
        return false;
    } else {
        [_favoritedUsers addObject:jid];
        return true;
    }
}

- (BOOL)isFavoritedByConnectedUser {
    NSString *jid = [NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
    return [_favoritedUsers containsObject:jid];
}

- (BOOL)isPostedByConnectedUser {
    NSString *jid = [NSString stringWithFormat:@"%@@%@", [ConnectionProvider getUser], [ConnectionProvider getServerIPAddress]];
    return ([_posterJID isEqualToString:jid]);
}

-(NSString *)getTimePosted {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [_createdTimestamp doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, h:mm a "];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:date];
}

-(void)startChat {
    NSString *chatID = [NSString stringWithFormat:@"%@%ld", [ConnectionProvider getUser],(long)[[NSDate date] timeIntervalSince1970]];
    [self encodeBody];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createCreateOneToOneChatFromConfessionPacket:self chatID:chatID]];
    NSString *invitedID = [[_posterJID componentsSeparatedByString:@"@"] firstObject];
    NSString *participants = [NSString stringWithFormat:@"%@, %@", [ConnectionProvider getUser], invitedID];
    [ChatDBManager setChatIDPendingCreation:chatID];
    [self decodeBody];
    [ChatDBManager insertChatWithID:chatID chatName:_body chatType:CHAT_TYPE_ONE_TO_ONE_CONFESSION participantString:participants status:STATUS_JOINED];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
}

-(NSString *)getTextForLabel {
    //return (_favoritedUsers.count == 1) ? @"1 Favorite" : [NSString stringWithFormat:@"%lu Favorites", (unsigned long)_favoritedUsers.count];
    return [NSString stringWithFormat:@"%lu", (unsigned long)_favoritedUsers.count];
}

-(NSUInteger)getNumForLabel {
    return _favoritedUsers.count;
}

-(void)deleteConfession {
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    [[cp getConnection] sendElement:[IQPacketManager createDestroyConfessionPacket:_confessionID]];
    [[ConfessionsManager getInstance] deleteConfession:_confessionID];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONFESSION_DELETED object:nil];
}

@end
