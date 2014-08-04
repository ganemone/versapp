//
//  ThoughtsCache.m
//  Versapp
//
//  Created by Giancarlo Anemone on 8/3/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ThoughtsCache.h"
#import "AppDelegate.h"
#import "ConnectionProvider.h"
#import "Base64.h"
#import "AFNetworking.h"
#import "Confession.h"
#import "Constants.h"

@interface ThoughtsCache()

@property (nonatomic, strong) NSMutableDictionary *thoughts;
@property (nonatomic, strong) NSMutableArray *thoughtIDValues;
@property BOOL shouldClearThoughts;

@end

@implementation ThoughtsCache

NSString *const THOUGHTS_METHOD_GLOBAL_STRING = @"global";
NSString *const THOUGHTS_METHOD_FRIENDS_STRING = @"friends";
NSString *const THOUGHTS_METHOD_YOU_STRING = @"you";

-(id)initWithMethod:(enum thoughtMethodTypes)thoughtMethod {
    self = [super init];
    if (self)
    {
        self.method = thoughtMethod;
        self.thoughts = [[NSMutableDictionary alloc] initWithCapacity:50];
        self.thoughtIDValues = [[NSMutableArray alloc] initWithCapacity:50];
    }
    return self;
}

-(int)getNumberOfConfessions {
    return (int)[_thoughts count];
}

-(Confession *)getConfessionAtIndex:(int)index {
    return [_thoughts objectForKey:[_thoughtIDValues objectAtIndex:index]];
}

-(Confession *)getConfessionWithID:(NSString *)confessionID {
    return [_thoughts objectForKey:confessionID];
}

-(NSString *)getSinceForThoughtRequest {
    NSArray *sortedThoughts = [[_thoughts objectsForKeys:_thoughtIDValues
                                          notFoundMarker:[NSNumber numberWithInt:10]]
                               sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
    {
                                   return [[obj1 createdTimestamp] compare:[obj2 createdTimestamp]];
    }];
    return [NSString stringWithFormat:@"%d", [[[sortedThoughts firstObject] createdTimestamp] intValue] - 1];
}

-(void)addConfession:(Confession *)confession {
    [_thoughts setObject:confession forKey:confession.confessionID];
    [_thoughtIDValues addObject:confession.confessionID];
}

-(void)updateConfession:(Confession *)confession {
    [_thoughts setObject:confession forKey:confession.confessionID];
}

-(void)sortConfessions {
    _thoughtIDValues = [NSMutableArray arrayWithArray:[_thoughtIDValues sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Confession *confession1 = [_thoughts objectForKey:obj1];
        Confession *confession2 = [_thoughts objectForKey:obj2];
        return [[confession2 createdTimestamp] compare:[confession1 createdTimestamp]];
    }]];
}

-(void)clearConfessions {
    [_thoughtIDValues removeAllObjects];
    [_thoughts removeAllObjects];
}

-(void)deleteConfession:(NSString *)confessionID {
    [_thoughts removeObjectForKey:confessionID];
}

-(NSUInteger)getIndexOfConfession:(NSString *)confessionID {
    return [_thoughtIDValues indexOfObject:confessionID];
}

-(void)loadConfessions {
    [self loadConfessionsSince:@"0"];
}

- (NSString *)getMethodString {
    switch (_method) {
        case THOUGHTS_METHOD_FRIENDS: return THOUGHTS_METHOD_FRIENDS_STRING;
        case THOUGHTS_METHOD_GLOBAL: return THOUGHTS_METHOD_GLOBAL_STRING;
        case THOUGHTS_METHOD_YOU: return THOUGHTS_METHOD_YOU_STRING;
        // SHOULD NEVER GET HERE
        default: return THOUGHTS_METHOD_GLOBAL_STRING;
    }
}

-(void)loadConfessionsSince:(NSString *)since {
    _shouldClearThoughts = ([since isEqualToString:@"0"]);
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"method" : [self getMethodString],
                                 @"since" : since};
    
    NSLog(@"Loading Confessions With Parameters: %@", parameters);
    
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer]
                                requestWithMethod:@"POST"
                                URLString:THOUGHTS_URL
                                parameters:parameters
                                error:&error];
    
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
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<entry>\"(.*?)\",\"(.*?)\",\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",(?:\\[\\]|\"(.*?)\"),\"(.*?)\",\"(.*?)\"</entry>"
                                                                           options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    NSString *confessionID, *jid, *body, *imageURL, *timestamp, *hasFavoritedString, *degree;
    NSNumber *favoriteCount;
    Confession *confession;
    
    if (_shouldClearThoughts) {
        [self clearConfessions];
    }
    
    for(NSTextCheckingResult *match in matches) {
        confessionID = [result substringWithRange:[match rangeAtIndex:1]];
        jid = [result substringWithRange:[match rangeAtIndex:2]];
        body = [result substringWithRange:[match rangeAtIndex:3]];
        if ([_thoughtIDValues containsObject:confessionID]) {
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

-(BOOL)hasCache {
    return ([_thoughtIDValues count] > 0);
}

@end
