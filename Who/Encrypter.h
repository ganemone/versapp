//
//  Encrypter.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encrypter : NSObject

+ (NSString *)md5:(NSString *)input;

+ (NSString *)sha1:(NSString *)input;

@end
