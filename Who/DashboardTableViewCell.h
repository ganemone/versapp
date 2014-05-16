//
//  DashboardTableViewCell.h
//  Versapp
//
//  Created by Giancarlo Anemone on 5/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMO.h"

@interface DashboardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *chatTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *chatName;
@property (weak, nonatomic) IBOutlet UILabel *lastMessage;

-(void)setUpWithChatMO:(ChatMO *)chatMo;

@end
