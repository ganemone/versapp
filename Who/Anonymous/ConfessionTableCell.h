//
//  ConfessionTableCell.h
//  Who
//
//  Created by Giancarlo Anemone on 2/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Confession.h"

@interface ConfessionTableCell : UITableViewCell

@property (weak, nonatomic, readonly) UIView *transparentBackgroundView;
@property (weak, nonatomic, readonly) UITextView *confessionText;
@property (weak, nonatomic, readonly) UIButton *favoriteButton;
@property (weak, nonatomic, readonly) UIButton *chatButton;
@property (strong, nonatomic) Confession *confession;

- (instancetype)initWithConfession:(Confession*)confession reuseIdentifier:(NSString*)reuseIdentifier;

@end
