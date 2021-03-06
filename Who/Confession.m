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
#import "ConfessionsManager.h"
#import "ThoughtsDBManager.h"
#import "NSString+URLEncode.h"
#import "XMPPManager.h"

@implementation Confession

+(instancetype)create:(NSString *)body imageURL:(NSString *)imageURL {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance setPosterJID:[ConnectionProvider getUser]];
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

+(instancetype)createWithThoughtMO:(ThoughtMO *)thought {
    BOOL hasFavorited = ([thought.hasFavorited isEqualToString:@"YES"]);
    return [Confession create:thought.body posterJID:thought.posterJID imageURL:thought.imageURL confessionID:thought.confessionID createdTimestamp:thought.createdTimestamp degreeOfConnection:thought.degree hasFavorited:hasFavorited numFavorites:[thought.numFavorites intValue]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Confession ID: %@ \n Body: %@ \n Poster JID: %@ \n Image URL: %@ \n Created Timestamp: %@ \n Has Favorited: %hhd \n Degree: %@ \n Num Favorites: %d", _confessionID, _body, _posterJID, _imageURL, _createdTimestamp, _hasFavorited, _degree, _numFavorites];
}

-(void)encodeBody {
    [self setBody: [_body urlEncode]];
}

-(void)decodeBody {
    [self setBody:[_body urlDecode]];
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
    return ([_posterJID isEqualToString:[ConnectionProvider getUser]]);
}

-(NSString *)getTimePosted {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [_createdTimestamp doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, h:mm a "];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:date];
}

-(void)startChat:(void (^)(ChatMO *element))block {
    NSString *chatID = [NSString stringWithFormat:@"%@%ld", [ConnectionProvider getUser],(long)[[NSDate date] timeIntervalSince1970]];
    [self encodeBody];
    NSString *invitedID = [[_posterJID componentsSeparatedByString:@"@"] firstObject];
    NSString *participants = [NSString stringWithFormat:@"%@, %@", [ConnectionProvider getUser], invitedID];
    [self decodeBody];
    ChatMO *chat = [ChatDBManager insertChatWithID:chatID chatName:_body chatType:CHAT_TYPE_ONE_TO_ONE_CONFESSION participantString:participants status:STATUS_JOINED degree:_degree];
    [ThoughtsDBManager insertThoughtWithID:_confessionID posterJID:_posterJID body:_body timestamp:_createdTimestamp degree:_degree favorites:[NSNumber numberWithInt:_numFavorites] hasFavorited:_hasFavorited imageURL:_imageURL];
    [ThoughtsDBManager setInConversationYes:_confessionID];
    XMPPManager *manager = [XMPPManager getInstance];
    [manager sendCreateOneToOneChatFromConfessionPacket:self chatID:chatID responseBlock:^(XMPPElement *element) {
        block(chat);
    }];
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
        return [UIImage imageNamed:@"friend-white.png"];
    } else if ([_degree isEqualToString:@"2"]) {
        return [UIImage imageNamed:@"second-degree-white.png"];
    } else {
        return [UIImage imageNamed:@"global-white.png"];
    }
}

@end
