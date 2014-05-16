//
//  ThoughtTableViewCell.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Confession.h"
#import "ImageManager.h"
@interface ThoughtTableViewCell : UITableViewCell<ImageManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIView *greyView;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) Confession  *confession;
@property CGFloat height;

- (void)setUpWithConfession:(Confession *)confession;
- (void)setUpBackgroundView;
- (CGFloat)heightForConfession;

@end
