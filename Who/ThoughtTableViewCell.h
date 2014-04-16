//
//  ThoughtTableViewCell.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThoughtTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIImageView *chatBtn;
@property (weak, nonatomic) IBOutlet UIImageView *favBtn;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@end
