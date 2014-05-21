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
#import "Base64.h"
#import "NSData+Base64.h"
#import "RSAESCryptor.h"

@implementation Encrypter

+(NSString *)md5:(NSString *)input {
    
    input = [self saltString:input];
    NSLog(@"Input: %@", input);
    
    // Create pointer to the string as UTF8
    const char *ptr = [input UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    NSLog(@"Returning Password: %@", output);
    return output;
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

+(NSString *)decryptRSA:(NSString *)cipherString key:(SecKeyRef) privateKey {
	size_t plainBufferSize = SecKeyGetBlockSize(privateKey);
	uint8_t *plainBuffer = malloc(plainBufferSize);
    NSData *incomingData = [cipherString dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t *cipherBuffer = (uint8_t*)[incomingData bytes];
	size_t cipherBufferSize = SecKeyGetBlockSize(privateKey);
	SecKeyDecrypt(privateKey,
                  kSecPaddingOAEP,
                  cipherBuffer,
                  cipherBufferSize,
                  plainBuffer,
                  &plainBufferSize);
	NSData *decryptedData = [NSData dataWithBytes:plainBuffer length:plainBufferSize];
	NSString *decryptedString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    return decryptedString;
}

+(NSString *)encryptRSA:(NSString *)plainTextString key:(SecKeyRef)publicKey {
    if (publicKey == nil) {
        NSLog(@"Nill public key reference");
        return nil;
    }
	size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
	uint8_t *cipherBuffer = malloc(cipherBufferSize);
	uint8_t *nonce = (uint8_t *)[plainTextString UTF8String];
	SecKeyEncrypt(publicKey,
                  kSecPaddingOAEP,
                  nonce,
                  strlen( (char*)nonce ),
                  &cipherBuffer[0],
                  &cipherBufferSize);
	NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
	return [Base64 encode:encryptedData];
}

+(NSData *)encryptStringWithRSAES:(NSString *)plainText {
    NSLog(@"Plain Text: %@", plainText);
    NSData *plainData = [plainText dataUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"Plain Data: %@", plainData);
    NSString *pubKeyPath = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"cer"];
    NSLog(@"Public Key Path: %@", pubKeyPath);
    RSAESCryptor *cryptor = [RSAESCryptor sharedCryptor];
    [cryptor loadPublicKey:pubKeyPath];
    NSData *encData = [cryptor encryptData:plainData];
    // encrypted data format:
    // [16 bytes IV] + [256 bytes encrypted Key] + [AES encrypted data].
    return encData;
}



@end



