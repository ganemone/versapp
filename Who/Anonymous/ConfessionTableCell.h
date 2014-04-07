//
//  ConfessionTableCell.h
//  Who
//
//  Created by Giancarlo Anemone on 2/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Confession.h"

@interface ConfessionTableCell : UITableViewCell<UIAlertViewDelegate>

@property (weak, nonatomic, readonly) UIView *containerView;
@property (weak, nonatomic, readonly) UIImageView *footerView;
@property (weak, nonatomic, readonly) UITextView *confessionText;
@property (weak, nonatomic, readonly) UIButton *favoriteButton;
@property (weak, nonatomic, readonly) UIButton *chatButton;
@property (weak, nonatomic, readonly) UILabel *favoriteLabel;
@property (weak, nonatomic, readonly) UILabel *conversationLabel;
@property (weak, nonatomic, readonly) UILabel *timestampLabel;
@property (weak, nonatomic, readonly) UIButton *deleteButton;

@property (strong, nonatomic) Confession *confession;

- (instancetype)initWithConfession:(Confession*)confession reuseIdentifier:(NSString*)reuseIdentifier;

+ (CGFloat)heightForConfession:(Confession*)confession;

@end
