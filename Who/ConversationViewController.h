//
//  ConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"
#import "JSMessagesViewController.h"

@interface ConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource> {
    IBOutlet UITableView *conversationTableView;
}
@property (strong, nonatomic) IBOutlet UITableView *conversationTableView;
@property (strong, nonatomic) GroupChat *gc;

@end
