//
//  RosterManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/7/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@interface RosterManager : NSObject

+(RosterManager *)getInstance;

-(UserProfile*)getRosterItem:(NSString*)jid;

-(void)addRosterItem:(UserProfile*)user;

@end
