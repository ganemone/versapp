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
#import "OneToOneChat.h"
#import "OneToOneChatManager.h"

@implementation Confession

+(instancetype)create:(NSString *)body imageURL:(NSString *)imageURL {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance setImageURL:imageURL];
    [instance setFavoritedUsers:[[NSMutableArray alloc] init]];
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
    return ([_posterJID compare:jid] == 0);
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
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createCreateOneToOneChatFromConfessionPacket:self chatID:chatID]];
    NSString *invitedID = [[_posterJID componentsSeparatedByString:@"@"] firstObject];
    OneToOneChat *chat = [OneToOneChat create:chatID inviterID:[ConnectionProvider getUser] invitedID:invitedID createdTimestamp:nil chatName:_body];
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    [cm addChat:chat];
    [cm setPendingChatID:chatID];    
}

@end
