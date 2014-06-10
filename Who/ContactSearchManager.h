//
//  ContactSearchManager.h
//  Who
//
//  Created by Giancarlo Anemone on 3/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactSearchManager : NSObject

+(instancetype)getInstance;

-(void)accessContacts;

-(void)updateContactListAfterUserSearch: (NSArray *)contactsFound;

-(void)postContactsToServer;


@end
