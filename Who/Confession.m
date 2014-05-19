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
    [instance setHasFavorited:NO];
    [instance setDegree:@"1"];
    [instance setNumFavorites:0];
    return instance;
}

+(instancetype)create:(NSString *)body posterJID:(NSString *)posterJID imageURL:(NSString *)imageURL confessionID:(NSString *)confessionID createdTimestamp:(NSString *)createdTimestamp degreeOfConnection:(NSString *)degree hasFavorited:(BOOL)hasFavorited numFavorites:(int)numFavorites {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance setPosterJID:posterJID];
    [instance setImageURL:imageURL];
    [instance setConfessionID:confessionID];
    [instance setCreatedTimestamp:createdTimestamp];
    [instance setHasFavorited:hasFavorited];
    [instance setDegree:degree];
    [instance setNumFavorites:numFavorites];
    return instance;
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
    _hasFavorited = !_hasFavorited;
    if (_hasFavorited) {
        _numFavorites++;
    } else {
        _numFavorites--;
    }
    return _hasFavorited;
}

- (BOOL)isFavoritedByConnectedUser {
    return _hasFavorited;
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
    [ChatDBManager insertChatWithID:chatID chatName:_body chatType:CHAT_TYPE_ONE_TO_ONE_CONFESSION participantString:participants status:STATUS_JOINED degree:_degree];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
}

-(NSString *)getTextForLabel {
    //return (_favoritedUsers.count == 1) ? @"1 Favorite" : [NSString stringWithFormat:@"%lu Favorites", (unsigned long)_favoritedUsers.count];
    return [NSString stringWithFormat:@"%d", _numFavorites];
}

-(NSUInteger)getNumForLabel {
    return _numFavorites;
}

-(void)deleteConfession {
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    [[cp getConnection] sendElement:[IQPacketManager createDestroyConfessionPacket:_confessionID]];
    [[ConfessionsManager getInstance] deleteConfession:_confessionID];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONFESSION_DELETED object:nil];
}

-(UIImage *)imageForDegree {
    if ([_degree isEqualToString:@"1"]) {
        return [UIImage imageNamed:@"thoughts-white-1.png"];
    } else if ([_degree isEqualToString:@"2"]) {
        return [UIImage imageNamed:@"thoughts-white-2.png"];
    } else if ([_degree isEqualToString:@"3"]) {
        return [UIImage imageNamed:@"thoughts-white-3.png"];
    } else {
        return [UIImage imageNamed:@"thoughts-global.png"];
    }
}

@end
