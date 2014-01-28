//
//  OneToOneConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneToOneChat.h"

@interface OneToOneConversationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    IBOutlet UITableView *conversationTableView;
    IBOutlet UITextField *messageTextField;
}

@property (strong, nonatomic) IBOutlet UITableView *conversationTableView;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) OneToOneChat *chat;

@end
