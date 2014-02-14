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

NSString *const DICTIONARY_KEY_DOWNLOADED_IMAGE = @"dictionary_key_downloaded_image";
NSString *const DICTIONARY_KEY_UPLOADED_IMAGE = @"dictionary_key_uploaded_image";
NSString *const DICTIONARY_KEY_IMAGE_URL = @"dictionary_key_downloaded_url";

@implementation ImageManager

-(void)downloadImageFromURL:(NSString *)url {
    [self performSelectorInBackground:@selector(performDownloadRequest:) withObject:url];
}

-(void)uploadImage:(UIImage *)image url:(NSString *)url {
    NSDictionary *uploadInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, DICTIONARY_KEY_UPLOADED_IMAGE, url, DICTIONARY_KEY_IMAGE_URL, nil];
    //[self performSelectorInBackground:@selector(performUploadRequest:) withObject:uploadInfo];
    [self performUploadRequest:uploadInfo];
}

-(void)performDownloadRequest:(NSString *)url {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:data];
    NSDictionary *downloadInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, DICTIONARY_KEY_DOWNLOADED_IMAGE, url, DICTIONARY_KEY_IMAGE_URL, nil];
    [self performSelectorOnMainThread:@selector(handleDownloadRequestFinished:) withObject:downloadInfo waitUntilDone:NO];
}

-(void)performUploadRequest:(NSDictionary*)uploadInfo {
    NSLog(@"Performing Upload Request...");
    UIImage *imageToUpload = [uploadInfo objectForKey:DICTIONARY_KEY_UPLOADED_IMAGE];
    NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 0.5f);
    
    NSURL *destURL = [NSURL URLWithString:[uploadInfo objectForKey:DICTIONARY_KEY_IMAGE_URL]];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:destURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    
    //Set request to post
    [uploadRequest setHTTPMethod:@"POST"];
    
    //Set content type
    [uploadRequest setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *postString = [NSString stringWithFormat:@"username=%@&session=%@&method=%@&image=%@", [ConnectionProvider getUser], delegate.sessionID, @"message", imageData];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding]; // Needs to be base 64 encoded...
    
    
    // Set authorization header if required
    
    // set data
    [uploadRequest setHTTPBody:postData];
    NSLog(@"Upload Request: %@", uploadRequest);
    // create connection and set delegate if needed
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:uploadRequest
                                                                      delegate:self
                                                              startImmediately:YES];
    NSLog(@"Created URL Connection...");
    [conn start];
    NSLog(@"Started URL Connection...");
}

-(void)handleDownloadRequestFinished:(NSDictionary*)downloadInfo {
    UIImage *image = [downloadInfo objectForKey:DICTIONARY_KEY_DOWNLOADED_IMAGE];
    NSString *url = [downloadInfo objectForKey:DICTIONARY_KEY_IMAGE_URL];
    [self.delegate didFinishDownloadingImage:image fromURL:url];
}

-(void)handleUploadRequestFinished:(NSDictionary*)uploadInfo {
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"Did Receive Data... %@", data);
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"Did Send Body Data");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Did finish loading...");
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed with error: %@", error);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Did receive NSURL Response: %@", response);
}

@end
