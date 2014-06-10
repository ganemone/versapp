//
//  ImageCache.h
//  Who
//
//  Created by Giancarlo Anemone on 2/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

+(ImageCache*)getInstance;

-(UIImage*)getImageByMessageSender:(NSString*)sender timestamp:(NSString*)timestamp;
-(UIImage *)getImageWithIdentifier:(NSString *)identifier;
-(BOOL)hasImageWithMessageSender:(NSString*)sender timestamp:(NSString*)timestamp;
-(BOOL)hasImageWithIdentifier:(NSString *)identifier;
-(void)setImage:(UIImage*)image sender:(NSString*)sender timestamp:(NSString*)timestamp;
-(void)setImage:(UIImage *)image withIdentifier:(NSString *)identifier;

@end
