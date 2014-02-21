//
//  Confession.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Confession.h"

@implementation Confession

+(instancetype)create:(NSString *)body imageURL:(NSString *)imageURL {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance encodeBody];
    [instance setImageURL:imageURL];
    [instance setFavoritedUsers:[[NSMutableArray alloc] init]];
    return instance;
}

+(instancetype)create:(NSString *)body imageURL:(NSString *)imageURL confessionID:(NSString *)confessionID createdTimestamp:(NSString *)createdTimestamp favoritedUsers:(NSMutableArray *)favoritedUsers {
    Confession *instance = [[Confession alloc] init];
    [instance setBody:body];
    [instance encodeBody];
    [instance setImageURL:imageURL];
    [instance setConfessionID:confessionID];
    [instance setCreatedTimestamp:createdTimestamp];
    [instance setFavoritedUsers:favoritedUsers];
    [instance setFavoriteCount:[NSNumber numberWithInt:[favoritedUsers count]]];
    return instance;
}

-(void)encodeBody {
    [self setBody: [self urlencode:_body]];
}

- (NSString *)urlencode:(NSString*)stringToEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[stringToEncode UTF8String];
    int sourceLen = strlen((const char *)source);
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

@end
