//
//  ImageManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageMO.h"

@protocol ImageManagerDelegate <NSObject>

@required

-(void)didFinishDownloadingImage:(UIImage*)image fromURL:(NSString*)url forMessage:(MessageMO*)message;

-(void)didFinishUploadingImage:(UIImage*)image toURL:(NSString*)url;

@end

@interface ImageManager : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) id <ImageManagerDelegate> delegate;

- (void)downloadImageForMessage:(MessageMO*)message;

- (void)uploadImage:(UIImage *)image url:(NSString*)url;

@end
