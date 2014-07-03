//
//  ImageManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageMO.h"
#import "Confession.h"
#import "ThoughtMO.h"

@protocol ImageManagerDelegate <NSObject>

@required

-(void)didFinishDownloadingImage:(UIImage*)image withIdentifier:(NSString*)identifier;
-(void)didFailToDownloadImageWithIdentifier:(NSString *)identifier;
-(void)didFinishUploadingImage:(UIImage*)image toURL:(NSString*)url;
-(void)didFailToUploadImage:(UIImage*)image toURL:(NSString*)url withError:(NSError *)error;

@end

@interface ImageManager : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) id <ImageManagerDelegate> delegate;

- (void)downloadImageForMessage:(MessageMO*)message delegate:(id<ImageManagerDelegate>)delegate;
- (void)downloadImageForThought:(Confession *)confession delegate:(id<ImageManagerDelegate>)delegate;
-(void)downloadImageForLocalThought:(ThoughtMO *)thought delegate:(id<ImageManagerDelegate>)delegate;
-(void)uploadImageToGCS:(UIImage *)image delegate:(id<ImageManagerDelegate>)delegate bucket:(NSString *)bucket;

@end
