//
//  OneToOneConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneToOneChat.h"
#import "JSMessagesViewController.h"

@interface OneToOneConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property (strong, nonatomic) OneToOneChat *chat;

@end
