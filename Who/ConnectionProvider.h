//
//  ConnectionProvider.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"

@interface ConnectionProvider : NSObject <XMPPStreamDelegate>

-(void) connect:(NSString*)username password:(NSString*)password;

+ (id) getInstance;

@end
