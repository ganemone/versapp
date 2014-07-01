//
//  Connection.h
//  The Arb
//
//  Created by Riley Lundquist on 6/26/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject

+(NSData *)makeRequestFor:(NSString *)info;

@end
