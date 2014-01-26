//
//  ConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"

@interface ConversationViewController : UITableViewController

@property (strong, nonatomic) GroupChat *gc;

@end
