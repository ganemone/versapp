//
//  ImageCache.m
//  Who
//
//  Created by Giancarlo Anemone on 2/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ImageCache.h"

@interface ImageCache()

@property (strong, nonatomic) NSMutableDictionary *images;

@end

static ImageCache *selfInstance;

@implementation ImageCache

// Class method (+) for getting instance of Connection Provider
+ (ImageCache*)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.images = [[NSMutableDictionary alloc] init];
        }
    }
    return selfInstance;
}

-(void)setImage:(UIImage *)image sender:(NSString *)sender timestamp:(NSString *)timestamp {
    [self.images setObject:image forKey:[NSString stringWithFormat:@"%@%@", sender, timestamp]];
}

-(void)setImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    [self.images setObject:image forKey:identifier];
}

-(BOOL)hasImageWithMessageSender:(NSString *)sender timestamp:(NSString *)timestamp {
    return ([self.images objectForKey:[NSString stringWithFormat:@"%@%@", sender, timestamp]] != nil);
}

-(UIImage *)getImageByMessageSender:(NSString *)sender timestamp:(NSString *)timestamp {
    return [self.images objectForKey:[NSString stringWithFormat:@"%@%@", sender, timestamp]];
}

-(BOOL)hasImageWithIdentifier:(NSString *)identifier {
    return ([self.images objectForKey:identifier] != nil);
}

-(UIImage *)getImageWithIdentifier:(NSString *)identifier {
    return [self.images objectForKey:identifier];
}

@end
