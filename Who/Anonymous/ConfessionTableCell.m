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

#import "Constants.h"

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
        CGFloat cellX = 8.0f;
        CGFloat cellY = 0.0f;
        CGSize contentSize = self.contentView.frame.size;
        CGFloat cellHeight = [ConfessionTableCell heightForConfession:confession];
        CGFloat textHeight = cellHeight - 50;
        CGRect cellFrame = CGRectMake(cellX, cellY, contentSize.width - 2*cellX, cellHeight);
        CGRect textFrame = CGRectMake(cellX, cellY, contentSize.width - 2*cellX, textHeight);
        CGRect footerFrame = CGRectMake(cellX, textHeight, contentSize.width - 2*cellX, cellFrame.size.width * 0.1176);
        
        // Configure Background View
        UIView *backgroundView = [[UIImageView alloc] initWithFrame:cellFrame];
        
        // Configure textview
        UITextView *textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.textContainerInset = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
        [textView setBackgroundColor:[UIColor whiteColor]];
        [textView setText:[confession body]];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[StyleManager getFontStyleLightSizeMed]];
        [textView setEditable:NO];
        
        // Configure Timstamp
        CGRect timestampLabelFrame = CGRectMake(cellX, textHeight - 15.0f, contentSize.width - 25.0f, 15.0f);
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:timestampLabelFrame];
        [timestampLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
        [timestampLabel setTextColor:[StyleManager getColorOrange]];
        [timestampLabel setTextAlignment:NSTextAlignmentRight];
        
        // Configure Footer View
        UIImageView *footer = [[UIImageView alloc] initWithFrame:footerFrame];
        [footer setImage:[UIImage imageNamed:@"confession-cell-bottom.png"]];
        
        // Configuring Chat Buttons
        CGFloat iconSize = 25.0f, paddingSmall = 5.0f;
        CGFloat labelWidth = (contentSize.width - 2.0f * cellX) / 2.0f;
        CGRect chatButtonFrame = CGRectMake(cellX + paddingSmall, textHeight + paddingSmall, iconSize, iconSize);
        CGRect chatLabelFrame = CGRectMake(cellX + iconSize + 2 * paddingSmall, textHeight + paddingSmall, labelWidth, iconSize);
        
        UIButton *createChatButton = [[UIButton alloc] initWithFrame:chatButtonFrame];
        [createChatButton addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *createChatLabel = [[UILabel alloc] initWithFrame:chatLabelFrame];
        UITapGestureRecognizer *chatTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfessionChatStarted:)];
        [createChatLabel setUserInteractionEnabled:YES];
        [createChatLabel addGestureRecognizer:chatTap];
        [createChatLabel setText:@"Chat"];
        [createChatLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
        
        // Configure Favorites
        CGRect favoriteButtonFrame = CGRectMake(contentSize.width - iconSize - cellX - 2 * paddingSmall, textHeight + paddingSmall, iconSize, iconSize);
        CGRect favoriteLabelFrame = CGRectMake(contentSize.width / 2 + iconSize, textHeight + paddingSmall, labelWidth, iconSize);
        
        UIButton *favoriteButton = [[UIButton alloc] initWithFrame:favoriteButtonFrame];
        [favoriteButton addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *favoriteLabel = [[UILabel alloc] initWithFrame:favoriteLabelFrame];
        [favoriteLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
        UITapGestureRecognizer *favoriteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfessionFavorited:)];
        [favoriteLabel setUserInteractionEnabled:YES];
        [favoriteLabel addGestureRecognizer:favoriteTap];
        
        // Add subviews
        [self.contentView addSubview:backgroundView];
        [self.contentView addSubview:textView];
        [self.contentView addSubview:footer];
        [self.contentView addSubview:createChatButton];
        [self.contentView addSubview:createChatLabel];
        [self.contentView addSubview:favoriteLabel];
        [self.contentView addSubview:favoriteButton];
        [self.contentView addSubview:timestampLabel];
        
        // Store variables
        _confessionText = textView;
        _containerView = backgroundView;
        _confession = confession;
        _footerView = footer;
        _chatButton = createChatButton;
        _favoriteButton = favoriteButton;
        _favoriteLabel = favoriteLabel;
        _timestampLabel = timestampLabel;
       
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
                recognizer.enabled = NO;
            }
        }
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                             action:@selector(handleLongPressGesture:)];
        [recognizer setMinimumPressDuration:0.4f];
        //    recognizer.delegate = self;
        [self addGestureRecognizer:recognizer];

    }
    return self;
}

+ (CGFloat)heightForConfession:(Confession*)confession {
    NSString *cellText = [confession body];
    UIFont *cellFont = [StyleManager getFontStyleLightSizeMed];
    //CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize labelSize = [cellText sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:cellFont, NSFontAttributeName, nil]];
    return labelSize.height + 80.0f;
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
    [_favoriteLabel setText:[_confession getTextForLabel]];
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

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    //    return;
    
//    NSLog(@"Long pressed!");
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
    
    UIAlertView *reportAbuse = [[UIAlertView alloc] initWithTitle:@"Report" message: @"Do you want to report abuse or block the sender?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:REPORT_ABUSE, REPORT_BLOCK,nil];
    
    reportAbuse.alertViewStyle = UIAlertViewStyleDefault;
    [reportAbuse show];
    //
    //    UIMenuController *menu = [UIMenuController sharedMenuController];
    //    CGRect targetRect = [self convertRect:[self.bubbleView bubbleFrame]
    //                                 fromView:self.bubbleView];
    //
    //    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    //
    //    self.bubbleView.bubbleImageView.highlighted = YES;
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(handleMenuWillShowNotification:)
    //                                                 name:UIMenuControllerWillShowMenuNotification
    //                                               object:nil];
    //    [menu setMenuVisible:YES animated:YES];
    }
}

- (void)alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:REPORT_ABUSE])
    {
        UIAlertView *report = [[UIAlertView alloc]initWithTitle:@"Report for abuse" message:@"Do you wish to report this message and its sender for abuse?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: REPORT_CONFIRM_ABUSE, nil];
        [report show];
    }
    else if ([title isEqualToString:REPORT_BLOCK])
    {
        UIAlertView *report = [[UIAlertView alloc]initWithTitle:@"Report for blocking" message:@"Do you wish to block this sender?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: REPORT_CONFIRM_BLOCK, nil];
        [report show];
    }
    else if ([title isEqualToString:REPORT_CONFIRM_ABUSE])
    {
        //TODO: implement report abuse method
    }
    else if ([title isEqualToString:REPORT_CONFIRM_BLOCK])
    {
        //TODO: implement block sender method
    }
    
}

@end
