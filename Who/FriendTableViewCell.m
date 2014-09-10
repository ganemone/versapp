//
//  FriendTableViewCell.m
//  Who
//
//  Created by Giancarlo Anemone on 3/18/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendTableViewCell.h"
#import "StyleManager.h"

@implementation FriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFriend:(FriendMO*)friendMO reuseIdentifier:(NSString*)reuseIdentifier {
    self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if(self) {
        if (friendMO.name != nil) {
            [self.textLabel setText:friendMO.name];
        } else {
            [self.textLabel setText:@"Loading..."];
        }
        
        [self.detailTextLabel setText:friendMO.username];
        
        CGFloat btnSize = 18.0f;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f, self.frame.size.height / 2 - btnSize/2, btnSize, btnSize)];
        
        [self.contentView addSubview:imageView];
        
        _isSelectedImageView = imageView;
    }
    return self;
}

-(void)setCellSelected {
    _isSelected = true;
    [_isSelectedImageView setImage:[UIImage imageNamed:@"cell-select-active.png"]];
}

-(void)setCellUnselected {
    _isSelected = false;
    [_isSelectedImageView setImage:[UIImage imageNamed:@"cell-select.png"]];
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.font = [StyleManager getFontStyleLightSizeLarge];
    self.textLabel.textColor = [StyleManager getColorPurple];
    self.textLabel.hidden = NO;
    
    self.detailTextLabel.hidden = NO;
    self.detailTextLabel.font = [StyleManager getFontStyleLightSizeMed];
    self.detailTextLabel.textColor = [StyleManager getColorPurple];
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

@end
