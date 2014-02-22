//
//  ConfessionTableCell.m
//  Who
//
//  Created by Giancarlo Anemone on 2/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionTableCell.h"
#import "Confession.h"
#import "ConfessionsManager.h"

#import "ConnectionProvider.h"
#import "IQPacketManager.h"

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
        CGFloat cellX = 10.0f;
        CGFloat cellY = 0.0f;
        CGSize contentSize = self.contentView.frame.size;
        CGFloat cellHeight = [self heightForConfession:confession];
        CGRect imageFrame = CGRectMake(cellX, cellY, contentSize.width - 20.0f, cellHeight);
        CGRect textFrame = CGRectMake(cellX + 10.0f, cellY, contentSize.width - 30.0f, cellHeight);
        
        UIView *backgroundView = [[UIImageView alloc] initWithFrame:imageFrame];
        [backgroundView setBackgroundColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:.30f]];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setText:[confession body]];
        [textView setTextColor:[UIColor whiteColor]];
        [textView setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
        
        CGFloat iconSize = 25.0f;
        CGRect chatButtonFrame = CGRectMake(cellX + (contentSize.width / 4.0f), cellHeight - 15.0f, iconSize, iconSize);
        CGRect favoriteButtonFrame = CGRectMake(cellX + 3 * (contentSize.width / 4.0f) - 2 * iconSize, cellHeight - 15.0f, iconSize, iconSize);
        UIButton *chatBtn = [[UIButton alloc] initWithFrame:chatButtonFrame];
        UIButton *favoriteBtn = [[UIButton alloc] initWithFrame:favoriteButtonFrame];
        [chatBtn setImage:[UIImage imageNamed:@"chat-icon.png"] forState:UIControlStateNormal];
        [favoriteBtn setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
        
        [favoriteBtn addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
        [chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:backgroundView];
        [self.contentView addSubview:textView];
        [self.contentView addSubview:chatBtn];
        [self.contentView addSubview:favoriteBtn];
        
        _confessionText = textView;
        _transparentBackgroundView = backgroundView;
        _confession = confession;
        _favoriteButton = favoriteBtn;
        _chatButton = chatBtn;
        
    }
    return self;
}

- (CGFloat)heightForConfession:(Confession*)confession {
    NSString *cellText = [confession body];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:16.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 30.0f;
}

-(void)handleConfessionFavorited:(id)sender {
    NSLog(@"Favoriting Confession: %@", [_confession confessionID]);
    [_favoriteButton setBackgroundColor:[UIColor blackColor]];
    
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createToggleFavoriteConfessionPacket:[_confession confessionID]]];
    
    [_confession toggleFavorite];
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    [confessionsManager updateConfession:_confession];
}

-(void)handleConfessionChatStarted:(id)sender {
    NSLog(@"Handling Confession Chat Started: %@", [_confession confessionID]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
