//
//  ImageCache.h
//  Who
//
//  Created by Giancarlo Anemone on 2/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

-(UIImage*)getImageByMessageSender:(NSString*)sender timestamp:(NSString*)timestamp;

-(BOOL)hasImageWithMessageSender:(NSString*)sender timestamp:(NSString*)timestamp;

-(void)setImage:(UIImage*)image sender:(NSString*)sender timestamp:(NSString*)timestamp;

@end
