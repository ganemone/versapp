//
//  FriendTableViewCell.h
//  Who
//
//  Created by Giancarlo Anemone on 3/18/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendMO.h"

@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *isSelectedImageView;
@property BOOL isSelected;

- (instancetype)initWithFriend:(FriendMO*)friendMO reuseIdentifier:(NSString*)reuseIdentifier;

- (void)setCellUnselected;

- (void)setCellSelected;

@end
