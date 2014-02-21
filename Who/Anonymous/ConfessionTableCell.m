//
//  ConfessionTableCell.m
//  Who
//
//  Created by Giancarlo Anemone on 2/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionTableCell.h"
#import "Confession.h"

@implementation ConfessionTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
}

- (instancetype)initWithConfession:(Confession*)confession reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier: reuseIdentifier];
    if (self) {
        CGFloat cellX = 0.0f;
        CGFloat cellY = 0.0f;
        CGSize contentSize = self.contentView.frame.size;
        CGRect imageFrame = CGRectMake(cellX, cellY, contentSize.width - 20.0f, contentSize.height);
        CGRect textFrame = CGRectMake(cellX + 10.0f, cellY, contentSize.width - 20.0f, contentSize.height);
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [backgroundImageView setImage:[UIImage imageNamed:@"bubble.png"]];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setText:[confession body]];
        //[textView setNumberOfLines:0];
        //[cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [textView setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
        
        [self.contentView addSubview:backgroundImageView];
        [self.contentView addSubview:textView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
