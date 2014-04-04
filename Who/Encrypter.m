//
//  Encrypter.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "Encrypter.h"
#import "Constants.h"

@implementation Encrypter

+(NSString *)md5:(NSString *)input {
    input = [self saltString:input];
    
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+(NSString *)sha1:(NSString *)input {
    input = [self saltString:input];
    
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(NSString *)saltString:(NSString *)input {
    return [NSString stringWithFormat:@"%@%@%@", SALT_ONE, input, SALT_TWO];
}

@end
