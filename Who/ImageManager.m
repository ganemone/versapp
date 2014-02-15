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
    NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 1.0f);
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
    //NSLog(@"Image: %@", encodedImageString);
    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    [uploadRequest setValue:[NSString stringWithFormat:@"%d", postString.length] forHTTPHeaderField:@"Content-Length"];
    [uploadRequest setHTTPBody:postData];

    // create connection and set delegate if needed
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:uploadRequest delegate:self];
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
    NSLog(@"Did Receive Data: %@ \n\n", [data base64Encoding]);
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

+ (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}
@end
