//
//  FriendTableViewCell.h
//  Who
//
//  Created by Giancarlo Anemone on 3/18/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIImageView *isSelectedImageView;
@property BOOL isSelected;

- (instancetype)initWithText:(NSString*)name reuseIdentifier:(NSString*)reuseIdentifier;

- (void)setCellUnselected;

- (void)setCellSelected;

@end
