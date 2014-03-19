//
//  ContactTableViewCell.m
//  Who
//
//  Created by Giancarlo Anemone on 3/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "StyleManager.h"
#import "FriendMO.h"
#import "Constants.h"

@implementation ContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.font = [StyleManager getFontStyleLightSizeLarge];
    self.textLabel.textColor = [StyleManager getColorGreen];
    self.textLabel.hidden = NO;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithFriend:(FriendMO *)friend reuseIdentifier:(NSString *)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        if (friend.name != nil) {
            [self.textLabel setText:friend.name];
        } else {
            [self.textLabel setText:@"Loading..."];
        }
        CGFloat btnSize = 18.0f;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f, self.frame.size.height / 2 - btnSize/2, btnSize, btnSize)];
        
        NSLog(@"Friend Status: %@", friend.status);
        NSString *imageName = ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_REGISTERED]]) ? @"cell-select.png" : @"cell-select-active.png";
        
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.contentView addSubview:btn];
        
        _actionBtn = btn;
        _friendMO = friend;
    }
    return self;
}

@end
