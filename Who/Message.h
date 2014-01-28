//
//  Message.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *sender;
@property (strong, nonatomic) NSString *chatID;
@property (strong, nonatomic) NSString *messageTo;

+(Message*)create:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID;

+(Message*)create:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID messageTo:(NSString*)messageTo;

@end
