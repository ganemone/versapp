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
@property (strong, nonatomic) NSString *timestamp;
@property (strong, nonatomic) NSString *messageTo;
@property (strong, nonatomic) NSString *imageLink;

+(Message*)createForMUC:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID;

+(Message*)createForMUCWithImage:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID imageLink:(NSString*)imageLink;

+(Message*)createForMUCWithImage:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID imageLink:(NSString*)imageLink timestamp:(NSString*)timestamp;

+(Message*)createForMUC:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID timestamp:(NSString*)timestamp;

+(Message*)createForOneToOne:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID messageTo:(NSString*)messageTo;

+(Message*)createForOneToOne:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID messageTo:(NSString*)messageTo timestamp:(NSString*)timestamp;

+(Message*)createForOneToOneWithImage:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID messageTo:(NSString*)messageTo imageLink:(NSString*)imageLink;

+(Message*)createForOneToOneWithImage:(NSString*)body sender:(NSString*)sender chatID:(NSString*)chatID messageTo:(NSString*)messageTo imageLink:(NSString*)imageLink timestamp:(NSString*)timestamp;


@end
