//
//  NSString+URLEncode.h
//  Versapp
//
//  Created by Giancarlo Anemone on 7/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncode)

- (NSString *)urlEncode;
- (NSString *)urlDecode;

@end
