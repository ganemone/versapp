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

-(void)downloadImageForMessage:(MessageMO *)message {
    
}

-(void)downloadImageForThought:(Confession *)confession {
    
}

- (NSURL*)getUploadURL {
    return [NSURL URLWithString:UPLOAD_URL];
}

- (NSURL*)getDownloadURL {
    return [NSURL URLWithString:DOWNLOAD_URL];
}

-(void)uploadImageToGCS:(UIImage *)image delegate:(id<ImageManagerDelegate>)delegate {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    NSString *encodedImageString = [Base64 encode:imageData];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *imageName = [NSString stringWithFormat:@"%@%d", [ConnectionProvider getUser], (int)timeStamp];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username" : [ConnectionProvider getUser],
                                 @"session" : appDelegate.sessionID,
                                 @"client_id" : CLIENT_ID,
                                 @"service_account_name" : SERVICE_ACCOUNT_NAME,
                                 @"key" : KEY_FILE_PATH,
                                 @"name" : imageName,
                                 @"data" : encodedImageString};
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:DOWNLOAD_URL parameters:parameters error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [delegate didFinishUploadingImage:image toURL:imageName];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate didFailToUploadImage:image toURL:imageName];
    }];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation start];
}

-(void)downloadImageFromGCSWithName:(NSString *)name fromBucket:(NSString *)bucket delegate:(id<ImageManagerDelegate>)delegate identifier:(NSString *)identifier {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"username" : [ConnectionProvider getUser],
                                 @"session" : appDelegate.sessionID,
                                 @"client_id" : CLIENT_ID,
                                 @"service_account_name" : SERVICE_ACCOUNT_NAME,
                                 @"key" : KEY_FILE_PATH,
                                 @"name" : name,
                                 @"bucket" : bucket};
    NSError *error = NULL;
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:DOWNLOAD_URL parameters:parameters error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[ImageCache getInstance] setImage:responseObject withIdentifier:identifier];
        [delegate didFinishDownloadingImage:responseObject withIdentifier:identifier];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [delegate didFailToDownloadImageWithIdentifier:identifier];
    }];
    [operation setResponseSerializer:[AFImageResponseSerializer serializer]];
    [operation start];
}

@end
