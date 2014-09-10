//
//  ImageManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/14/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ImageManager.h"
#import "ConnectionProvider.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "ImageCache.h"
#import "Constants.h"
#import "AFHTTPRequestOperationManager.h"

NSString *const DICTIONARY_KEY_DOWNLOADED_IMAGE = @"dictionary_key_downloaded_image";
NSString *const DICTIONARY_KEY_UPLOADED_IMAGE = @"dictionary_key_uploaded_image";
NSString *const DICTIONARY_KEY_IMAGE_URL = @"dictionary_key_downloaded_url";
NSString *const DICTIONARY_KEY_MESSAGE = @"dictionary_key_message";

@interface ImageManager()

@property(strong, nonatomic) UIImage *uploadingImage;

@end

@implementation ImageManager

-(void)downloadImageForMessage:(MessageMO *)message delegate:(id<ImageManagerDelegate>)delegate {
    [self downloadImageFromGCSWithName:message.image_link fromBucket:BUCKET_MESSAGES delegate:delegate identifier:message.image_link];
}

-(void)downloadImageForThought:(Confession *)confession delegate:(id<ImageManagerDelegate>)delegate {
    [self downloadImageFromGCSWithName:confession.imageURL fromBucket:BUCKET_THOUGHTS delegate:delegate identifier:confession.confessionID];
}

-(void)downloadImageForLocalThought:(ThoughtMO *)thought delegate:(id<ImageManagerDelegate>)delegate {
    [self downloadImageFromGCSWithName:thought.imageURL fromBucket:BUCKET_THOUGHTS delegate:delegate identifier:thought.confessionID];
}

- (NSURL*)getUploadURL {
    return [NSURL URLWithString:UPLOAD_URL];
}

- (NSURL*)getDownloadURL {
    return [NSURL URLWithString:DOWNLOAD_URL];
}

-(void)uploadImageToGCS:(UIImage *)image delegate:(id<ImageManagerDelegate>)delegate bucket:(NSString *)bucket {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    NSString *encodedImageString = [Base64 encode:imageData];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *imageName = [NSString stringWithFormat:@"%@%d", [ConnectionProvider getUser], (int)timeStamp];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username" : [ConnectionProvider getUser],
                                 @"session" : appDelegate.sessionID,
                                 @"name" : imageName,
                                 @"data" : encodedImageString,
                                 @"bucket" : bucket};
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:UPLOAD_URL parameters:parameters error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [delegate didFinishUploadingImage:image toURL:imageName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate didFailToUploadImage:image toURL:imageName withError:error];
    }];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation start];
}

-(void)downloadImageFromGCSWithName:(NSString *)name fromBucket:(NSString *)bucket delegate:(id<ImageManagerDelegate>)delegate identifier:(NSString *)identifier {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username" : [ConnectionProvider getUser],
                                 @"session" : appDelegate.sessionID,
                                 @"name" : name,
                                 @"bucket" : bucket};
    
    [manager setResponseSerializer:[AFImageResponseSerializer serializer]];
    [manager POST:DOWNLOAD_URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil) {
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ImageCache getInstance] setImage:responseObject withIdentifier:identifier];
                [delegate didFinishDownloadingImage:responseObject withIdentifier:identifier];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate didFailToDownloadImageWithIdentifier:identifier];
    }];
}

@end
