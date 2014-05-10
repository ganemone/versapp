//
//  BlacklistManager.h
//  Versapp
//
//  Created by Giancarlo Anemone on 5/7/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlacklistManager : NSObject

+ (void)sendPostRequestWithPhoneNumbers:(NSArray *)phoneNumbers emails:(NSArray *)emails;

@end
