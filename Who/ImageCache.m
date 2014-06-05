//
//  ImageCache.m
//  Who
//
//  Created by Giancarlo Anemone on 2/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ImageCache.h"
#import "NSMutableArray+QueueAdditions.h"

@interface ImageCache()

@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSMutableArray *imageIdentifiers;

@end

static ImageCache *selfInstance;

@implementation ImageCache

// Class method (+) for getting instance of Connection Provider
+ (ImageCache*)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.images = [[NSMutableDictionary alloc] initWithCapacity:10];
            selfInstance.imageIdentifiers = [[NSMutableArray alloc] initWithCapacity:10];
        }
    }
    return selfInstance;
}

-(void)setImage:(UIImage *)image sender:(NSString *)sender timestamp:(NSString *)timestamp {
    [self.images setObject:image forKey:[NSString stringWithFormat:@"%@%@", sender, timestamp]];
}

-(void)setImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    if ([_imageIdentifiers count] == 10) {
        NSString *identifier = [_imageIdentifiers dequeue];
        [_images removeObjectForKey:identifier];
    }
    [_imageIdentifiers enqueue:identifier];
    [_images setObject:image forKey:identifier];
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
