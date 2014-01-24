//
//  Chat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Chat.h"
#import "ConnectionProvider.h"

@implementation Chat

-(History *)getHistory {
    return self.history;
}

-(void)sendMessage:(Message *)message image:(UIImage *)image {
    
}

-(NSString *)getChatAddress {
    return [NSString stringWithFormat:@"%@@%@", self.chatID, [ConnectionProvider getConferenceIPAddress]];
}



@end
