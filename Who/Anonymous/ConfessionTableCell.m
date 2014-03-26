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

static UIImage *footerImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (footerImage == nil) {
        footerImage = [UIImage imageNamed:@"confession-cell-bottom.png"];
    }
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
        if ([confession hasCalculatedFrames] == NO) {
            NSLog(@"Calculating Frames on Main Thread... :(");
            [confession calculateFramesForTableViewCell:self.contentView.frame.size];
        }
        // Configure Background View
        UIView *backgroundView = [[UIImageView alloc] initWithFrame:confession.cellFrame];
        
        // Configure textview
        UITextView *textView = [[UITextView alloc] initWithFrame:confession.textFrame];
        textView.textContainerInset = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
        [textView setText:[confession body]];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[StyleManager getFontStyleLightSizeMed]];
        [textView setBackgroundColor:[UIColor whiteColor]];
        [textView setEditable:NO];
        
        // Configure Timstamp
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:confession.timestampLabelFrame];
        [timestampLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
        [timestampLabel setTextColor:[StyleManager getColorOrange]];
        [timestampLabel setTextAlignment:NSTextAlignmentRight];
        
        // Configure Footer View
        UIImageView *footer = [[UIImageView alloc] initWithFrame:confession.footerFrame];
        [footer setImage: footerImage];
        
        // Configuring Chat Buttons
        UIButton *createChatButton = [[UIButton alloc] initWithFrame:confession.chatButtonFrame];
        [createChatButton addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *createChatLabel = [[UILabel alloc] initWithFrame:confession.chatLabelFrame];
        UITapGestureRecognizer *chatTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleConfessionChatStarted:)];
        [createChatLabel setUserInteractionEnabled:YES];
        [createChatLabel addGestureRecognizer:chatTap];
        [createChatLabel setText:@"Chat"];
        [createChatLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
        
        // Configure Favorites
        UIButton *favoriteButton = [[UIButton alloc] initWithFrame:confession.favoriteButtonFrame];
        [favoriteButton addTarget:self action:@selector(handleConfessionFavorited:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *favoriteLabel = [[UILabel alloc] initWithFrame:confession.favoriteLabelFrame];
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
        
        /*for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
         if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
         recognizer.enabled = NO;
         }
         }
         
         UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                             action:@selector(handleLongPressGesture:)];
         [recognizer setMinimumPressDuration:0.4f];
         //    recognizer.delegate = self;
         [self addGestureRecognizer:recognizer];*/
        
    }
    return self;
}

+ (CGFloat)heightForConfession:(Confession*)confession {
    return [confession heightForConfession];
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
