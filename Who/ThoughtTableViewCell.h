//
//  ThoughtTableViewCell.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/16/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Confession.h"

@interface ThoughtTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UIImageView *chatBtn;
@property (weak, nonatomic) IBOutlet UIImageView *favBtn;
@property (weak, nonatomic) IBOutlet UILabel *favLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) Confession  *confession;

-(void)setUpWithConfession:(Confession *)confession;

@end
