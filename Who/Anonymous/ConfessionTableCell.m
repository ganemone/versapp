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
#import "StyleManager.h"

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
        CGFloat cellHeight = [ConfessionTableCell heightForConfession:confession];
        CGRect imageFrame = CGRectMake(cellX, cellY, contentSize.width - 20.0f, cellHeight);
        CGRect textFrame = CGRectMake(cellX, cellY, contentSize.width - 20.0f, cellHeight - 40);
        CGRect footerFrame = CGRectMake(cellX, cellHeight - 40, contentSize.width - 20.0f, imageFrame.size.width * 0.1176);
        
        // Configure Background View
        UIView *backgroundView = [[UIImageView alloc] initWithFrame:imageFrame];
        /*[backgroundView setBackgroundColor:[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:.30f]];
        [backgroundView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [backgroundView.layer setBorderWidth:1.0f];
        [backgroundView.layer setCornerRadius:5.0f];*/
        
        // Configure textview
        UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
        [textView setBackgroundColor:[UIColor whiteColor]];
        [textView setText:[confession body]];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[StyleManager getFontStyleLightSizeMed]];
        [textView setEditable:NO];
        
        // Configure Footer View
        UIImageView *footer = [[UIImageView alloc] initWithFrame:footerFrame];
        [footer setImage:[UIImage imageNamed:@"confession-cell-bottom.png"]];
        
        // Configuring Chat Buttons
        CGFloat iconSize = 25.0f, paddingSmall = 5.0f;
        CGFloat labelWidth = (contentSize.width - 2.0f * cellX) / 2.0f;
        CGRect chatButtonFrame = CGRectMake(cellX + paddingSmall, cellHeight - 40 + paddingSmall, iconSize, iconSize);
        CGRect chatLabelFrame = CGRectMake(cellX + iconSize + 2 * paddingSmall, cellHeight - 40 + paddingSmall, labelWidth, iconSize);
        
        UIButton *createChatButton = [[UIButton alloc] initWithFrame:chatButtonFrame];
        UILabel *createChatLabel = [[UILabel alloc] initWithFrame:chatLabelFrame];
        [createChatLabel setText:@"Converse"];
        
        // Configure Favorites
        
        // Add subviews
        [self.contentView addSubview:backgroundView];
        [self.contentView addSubview:textView];
        [self.contentView addSubview:footer];
        [self.contentView addSubview:createChatButton];
        [self.contentView addSubview:createChatLabel];

        // Store variables
        _confessionText = textView;
        _containerView = backgroundView;
        _confession = confession;
        _footerView = footer;
        _chatButton = createChatButton;
        /*
        _favoriteButton = favoriteBtn;
        _chatButton = chatBtn;
        _favoriteCountLabel = label;
        _gradLine = underlineView;
        */
    }
    return self;
}

+ (CGFloat)heightForConfession:(Confession*)confession {
    NSString *cellText = [confession body];
    UIFont *cellFont = [StyleManager getFontStyleLightSizeMed];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 100.0f;
}

-(void)handleConfessionFavorited:(id)sender {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createToggleFavoriteConfessionPacket:[_confession confessionID]]];
    
    BOOL isFavorited = [_confession toggleFavorite];
    NSLog(@"Is Favorited... %d", [_confession isFavoritedByConnectedUser]);
    if (isFavorited) {
        [_favoriteButton setImage:[UIImage imageNamed:@"fav-icon-active.png"] forState:UIControlStateNormal];
    } else {
        [_favoriteButton setImage:[UIImage imageNamed:@"fav-icon.png"] forState:UIControlStateNormal];
    }
    //[_favoriteLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[[_confession favoritedUsers] count]]];
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    [confessionsManager updateConfession:_confession];
}

-(void)handleConfessionChatStarted:(id)sender {
    [_confession startChat];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
