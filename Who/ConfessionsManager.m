//
//  ConfessionsManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionsManager.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "Base64.h"
#import "FriendsDBManager.h"
#import "ThoughtsDBManager.h"
#import "ThoughtsCache.h"

static ConfessionsManager *selfInstance;

@implementation ConfessionsManager

+ (instancetype) getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            [selfInstance setMethod:THOUGHTS_METHOD_GLOBAL];
            [selfInstance setFriends:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_FRIENDS]];
            [selfInstance setGlobal:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_GLOBAL]];
            [selfInstance setYou:[[ThoughtsCache alloc] initWithMethod:THOUGHTS_METHOD_YOU]];
        }
    }
    return selfInstance;
}

-(ThoughtsCache *)getCurrentCache {
    switch (self.method) {
        case THOUGHTS_METHOD_FRIENDS: return _friends;
        case THOUGHTS_METHOD_GLOBAL: return _global;
        default: return _you;
    }
}

-(int)getNumberOfConfessions {
    return [[self getCurrentCache] getNumberOfConfessions];
}

-(Confession *)getConfessionAtIndex:(int)index {
    return [[self getCurrentCache] getConfessionAtIndex:index];
}

-(Confession *)getConfessionWithID:(NSString *)confessionID {
    return [[self getCurrentCache] getConfessionWithID:confessionID];
}

-(NSString *)getSinceForThoughtRequest {
    return [[self getCurrentCache] getSinceForThoughtRequest];
}

-(void)addConfession:(Confession *)confession {
    [[self getCurrentCache] addConfession:confession];
}

-(void)updateConfession:(Confession *)confession {
    [[self getCurrentCache] updateConfession:confession];
}

-(void)updatePendingConfession:(NSString*)confessionID timestamp:(NSString*)timestamp {
    [_pendingConfession setConfessionID:confessionID];
    [_pendingConfession setCreatedTimestamp:timestamp];
    [_pendingConfession decodeBody];
    [self addConfession:_pendingConfession];
    
    [ThoughtsDBManager insertThoughtWithID:confessionID posterJID:_pendingConfession.posterJID body:_pendingConfession.body timestamp:_pendingConfession.createdTimestamp degree:_pendingConfession.degree favorites:[NSNumber numberWithInt:_pendingConfession.numFavorites] hasFavorited:NO imageURL:_pendingConfession.imageURL];
    [ThoughtsDBManager setHasFavoritedNo:confessionID];
    [ThoughtsDBManager setInConversationNo:confessionID];
    
    [self setPendingConfession:nil];
}

-(void)sortConfessions {
    [[self getCurrentCache] sortConfessions];
}

-(void)deleteConfession:(NSString *)confessionID {
    [[self getCurrentCache] deleteConfession:confessionID];
}

-(NSUInteger)getIndexOfConfession:(NSString *)confessionID {
    return [[self getCurrentCache] getIndexOfConfession:confessionID];
}

-(void)loadConfessions {
    [[self getCurrentCache] loadConfessions];
}

-(void)loadConfessionsSince:(NSString *)since {
    [[self getCurrentCache] loadConfessionsSince:since];
}

-(BOOL)hasCache {
    return [[self getCurrentCache] hasCache];
}

-(void)loadConfessionByID:(NSString *)cid withBlock:(void (^)(Confession *confession))block {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *parameters = @{@"method": cid};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                             URLString:THOUGHTS_URL
                                                                            parameters:parameters
                                                                                 error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Succeeded with operation: %@", operation.responseString);
        NSLog(@"Succeeded with response object: %@", responseObject);
        Confession *result = [self handleReceivedConfessionsRequest:operation.responseString];
        NSLog(@"Resulting Confession: %@", [result description]);
        block(result);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", error);
    }];
    
    // Setting up authorization header
    NSString *authCode = [NSString stringWithFormat:@"%@:%@", [ConnectionProvider getUser], delegate.sessionID];
    NSData *data = [authCode dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64AuthCode = [Base64 encode:data];
    NSString *authHttpHeaderValue = [NSString stringWithFormat:@"Basic %@", base64AuthCode];
    [req addValue:authHttpHeaderValue forHTTPHeaderField:BLACKLIST_AUTH_CODE];
    [operation setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
    [operation start];
}

-(Confession *)handleReceivedConfessionsRequest:(NSString *)result {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<entry>\"(.*?)\",\"(.*?)\",\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",\"(.*?)\"</entry>"
                                                                           options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:result options:0 range:NSMakeRange(0, result.length)];
    NSString *confessionID, *jid, *body, *imageURL, *timestamp, *hasFavoritedString, *degree;
    NSNumber *favoriteCount;
    Confession *confession;
    confessionID = [result substringWithRange:[match rangeAtIndex:1]];
    jid = [result substringWithRange:[match rangeAtIndex:2]];
    body = [result substringWithRange:[match rangeAtIndex:3]];
    if ([match rangeAtIndex:4].length != 0) {
        imageURL = [result substringWithRange:[match rangeAtIndex:4]];
    }
    timestamp = [result substringWithRange:[match rangeAtIndex:5]];
    if ([match rangeAtIndex:6].length != 0) {
        hasFavoritedString = [result substringWithRange:[match rangeAtIndex:6]];
    }
    if ([match rangeAtIndex:7].length != 0) {
        favoriteCount = [NSNumber numberWithInteger:[[result substringWithRange:[match rangeAtIndex:7]] integerValue]];
    }
        
    degree = [result substringWithRange:[match rangeAtIndex:8]];
    BOOL hasFavorited = ([hasFavoritedString isEqualToString:@"YES"]) ? YES : NO;
        
    if (!(imageURL.length > 0) || [imageURL isEqualToString:@"null"]) {
        imageURL = @"g1398792552";
    }
    body = [[body stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    confession = [Confession create:body posterJID:jid imageURL:imageURL confessionID:confessionID createdTimestamp:timestamp degreeOfConnection:degree hasFavorited:hasFavorited numFavorites:[favoriteCount intValue]];
    return  confession;
}

-(void)synchronizeThoughtWithID:(NSString *)cid withBlock:(void (^)(ThoughtMO *thought))block {
    [self loadConfessionByID:cid withBlock:^(Confession *confession) {
        ThoughtMO *thought = [ThoughtsDBManager getThoughtWithID:cid];
        if (thought == nil) {
            thought = [ThoughtsDBManager insertThoughtWithConfession:confession];
        } else {
            thought = [ThoughtsDBManager updateThought:thought withConfession:confession];
        }
        block(thought);
    }];
}


@end
