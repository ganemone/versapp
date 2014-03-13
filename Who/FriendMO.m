//
//  FriendMO.m
//  Who
//
//  Created by Giancarlo Anemone on 3/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendMO.h"


@implementation FriendMO

@dynamic email;
@dynamic name;
@dynamic status;
@dynamic username;
@dynamic searchedEmail;
@dynamic searchedPhoneNumber;

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ \n %@ \n %@ \n %@ \n %@ \n %@", self.email, self.name, self.status, self.username, self.searchedEmail, self.searchedPhoneNumber];
}

@end
