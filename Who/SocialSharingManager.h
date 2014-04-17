//
//  FBSharingManager.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/17/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

@interface SocialSharingManager : NSObject

+ (void) shareVersappFBLink;
+ (SLComposeViewController *)getTweetSheet;
@end
