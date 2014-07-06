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

static ConfessionsManager *selfInstance;

@implementation ConfessionsManager

+ (instancetype) getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            [selfInstance setConfessions:[[NSMutableDictionary alloc] initWithCapacity:100]];
            [selfInstance setConfessionIDValues:[[NSMutableArray alloc] initWithCapacity:100]];
        }
    }
    return selfInstance;
}

-(int)getNumberOfConfessions {
    return (int)[_confessions count];
}

-(Confession *)getConfessionAtIndex:(int)index {
    return [_confessions objectForKey:[_confessionIDValues objectAtIndex:index]];
}

-(Confession *)getConfessionWithID:(NSString *)confessionID {
    return [_confessions objectForKey:confessionID];
}

-(NSString *)getSinceForThoughtRequest {
    NSArray *sortedThoughts = [[_confessions objectsForKeys:_confessionIDValues notFoundMarker:[NSNumber numberWithInt:10]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 createdTimestamp] compare:[obj2 createdTimestamp]];
    }];
    return [NSString stringWithFormat:@"%d", [[[sortedThoughts firstObject] createdTimestamp] intValue] - 1];
}

-(void)addConfession:(Confession *)confession {
    [self.confessions setObject:confession forKey:confession.confessionID];
    [self.confessionIDValues addObject:confession.confessionID];
}

-(void)updateConfession:(Confession *)confession {
    [self.confessions setObject:confession forKey:confession.confessionID];
}

-(void)updatePendingConfession:(NSString*)confessionID timestamp:(NSString*)timestamp {
    [_pendingConfession setConfessionID:confessionID];
    [_pendingConfession setCreatedTimestamp:timestamp];
    [_pendingConfession decodeBody];
    [self addConfession:_pendingConfession];
    
    [ThoughtsDBManager insertThoughtWithID:confessionID posterJID:_pendingConfession.posterJID body:_pendingConfession.body timestamp:_pendingConfession.createdTimestamp degree:_pendingConfession.degree favorites:[NSNumber numberWithInt:_pendingConfession.numFavorites] imageURL:_pendingConfession.imageURL];
    [ThoughtsDBManager setHasFavoritedNo:confessionID];
    [ThoughtsDBManager setInConversationNo:confessionID];
    
    [self setPendingConfession:nil];
}

-(void)sortConfessions {
    _confessionIDValues = [NSMutableArray arrayWithArray:[_confessionIDValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Confession *confession1 = [_confessions objectForKey:obj1];
        Confession *confession2 = [_confessions objectForKey:obj2];
        return [[confession2 createdTimestamp] compare:[confession1 createdTimestamp]];
    }]];
}

-(void)clearConfessions {
    [_confessionIDValues removeAllObjects];
    [_confessions removeAllObjects];
}

-(void)deleteConfession:(NSString *)confessionID {
    [_confessions removeObjectForKey:confessionID];
}

-(NSUInteger)getIndexOfConfession:(NSString *)confessionID {
    return [_confessionIDValues indexOfObject:confessionID];
}

-(void)loadConfessionsWithMethod:(NSString *)method {
    [self loadConfessionsWithMethod:method since:@"0"];
}

-(void)loadConfessionsWithMethod:(NSString *)method since:(NSString *)since {
    
    /*if (![FriendsDBManager hasEnoughFriends]) {
        method = @"global";
    }*/
    
    if ([since isEqualToString:@"0"]) {
        _shouldClearConfessions = YES;
    } else {
        _shouldClearConfessions = NO;
    }
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"method" : method,
                                 @"since" : since};
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"https://versapp.co/thoughts/index.php" parameters:parameters error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Loaded thoughts with request: %@", since);
        NSLog(@"Loaded thoughts with response: %@", operation.responseString);

        [self handleReceivedConfessionsRequest:operation.responseString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with response: %@", operation.responseString);
        NSLog(@"Failed Thought request: %@", error);
    }];
    // Setting up authorization header
    NSString *authCode = [NSString stringWithFormat:@"%@:%@", [ConnectionProvider getUser], appDelegate.sessionID];
    NSData *data = [authCode dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64AuthCode = [Base64 encode:data];
    NSString *authHttpHeaderValue = [NSString stringWithFormat:@"Basic %@", base64AuthCode];
    [req addValue:authHttpHeaderValue forHTTPHeaderField:BLACKLIST_AUTH_CODE];
    [operation setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
    [operation start];
}

-(void)handleReceivedConfessionsRequest:(NSString *)result {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<entry>\"(.*?)\",\"(.*?)\",\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",\"(.*?)\"</entry>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    NSString *confessionID, *jid, *body, *imageURL, *timestamp, *hasFavoritedString, *degree;
    NSNumber *favoriteCount;
    Confession *confession;
    
    if (_shouldClearConfessions) {
        [self clearConfessions];
    }
    
    for(NSTextCheckingResult *match in matches) {
        confessionID = [result substringWithRange:[match rangeAtIndex:1]];
        jid = [result substringWithRange:[match rangeAtIndex:2]];
        body = [result substringWithRange:[match rangeAtIndex:3]];
        if ([_confessionIDValues containsObject:confessionID]) {
            NSLog(@"Duplicate Found: %@", body);
            continue;
        }
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
        [self addConfession:confession];
    }
    
    [self sortConfessions];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_CONFESSIONS object:nil];
}

@end
