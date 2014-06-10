//
//  ContactTableViewCell.h
//  Who
//
//  Created by Giancarlo Anemone on 3/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendMO.h"

@interface ContactTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIButton *actionBtn;
@property (strong, nonatomic) FriendMO *friendMO;

- (instancetype)initWithFriend:(FriendMO*)name reuseIdentifier:(NSString*)reuseIdentifier;

@end
