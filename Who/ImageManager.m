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

NSString *const DICTIONARY_KEY_DOWNLOADED_IMAGE = @"dictionary_key_downloaded_image";
NSString *const DICTIONARY_KEY_UPLOADED_IMAGE = @"dictionary_key_uploaded_image";
NSString *const DICTIONARY_KEY_IMAGE_URL = @"dictionary_key_downloaded_url";
NSString *const DICTIONARY_KEY_MESSAGE = @"dictionary_key_message";

@interface ImageManager()

@property(strong, nonatomic) UIImage *uploadingImage;

@end

@implementation ImageManager

-(void)downloadImageForMessage:(MessageMO *)message {
    [self performSelectorInBackground:@selector(performDownloadRequest:) withObject:message];
}

-(void)uploadImage:(UIImage *)image url:(NSString *)url {
    NSLog(@"Uploading Image: %@ to URL %@", [image description], url);
    NSDictionary *uploadInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, DICTIONARY_KEY_UPLOADED_IMAGE, url, DICTIONARY_KEY_IMAGE_URL, nil];
    //[self performSelectorInBackground:@selector(performUploadRequest:) withObject:uploadInfo];
    [self performUploadRequest:uploadInfo];
}

-(void)performDownloadRequest:(MessageMO *)message {
    NSString *url = message.image_link;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];
    NSDictionary *downloadInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, DICTIONARY_KEY_DOWNLOADED_IMAGE, url, DICTIONARY_KEY_IMAGE_URL, message, DICTIONARY_KEY_MESSAGE, nil];
    [self performSelectorOnMainThread:@selector(handleDownloadRequestFinished:) withObject:downloadInfo waitUntilDone:NO];
}

-(void)performUploadRequest:(NSDictionary*)uploadInfo {
    self.uploadingImage = [uploadInfo objectForKey:DICTIONARY_KEY_UPLOADED_IMAGE];
    NSData *imageData = UIImageJPEGRepresentation(self.uploadingImage, 0.5f);
    NSString *encodedImageString = [Base64 encode:imageData];
    
    NSURL *destURL = [NSURL URLWithString:[uploadInfo objectForKey:DICTIONARY_KEY_IMAGE_URL]];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:destURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    
    //Set request to post
    [uploadRequest setHTTPMethod:@"POST"];
    
    //Set content type
    [uploadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *postString = [NSString stringWithFormat:@"username=%@&session=%@&method=%@&image=%@", [ConnectionProvider getUser], delegate.sessionID, @"message", encodedImageString];
    postString = [postString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    [uploadRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postString.length] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody:postData];

    // create connection and set delegate if needed
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self];
    [conn start];
}

-(void)handleDownloadRequestFinished:(NSDictionary*)downloadInfo {
    UIImage *image = [downloadInfo objectForKey:DICTIONARY_KEY_DOWNLOADED_IMAGE];
    NSString *url = [downloadInfo objectForKey:DICTIONARY_KEY_IMAGE_URL];
    MessageMO *message = [downloadInfo objectForKey:DICTIONARY_KEY_MESSAGE];
    [[ImageCache getInstance] setImage:image sender:message.sender_id timestamp:message.time];
    [self.delegate didFinishDownloadingImage:image fromURL:url forMessage:message];
}

-(void)handleUploadRequestFinished:(NSDictionary*)uploadInfo {
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *imageURL = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    [self.delegate didFinishUploadingImage:self.uploadingImage toURL:imageURL];
}

/*-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}*/

@end
