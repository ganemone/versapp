//
//  ConversationViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConversationViewController.h"
#import "Constants.h"
#import "MessagesDBManager.h"
#import "MessageMO.h"
#import <QuartzCore/QuartzCore.h>
#import "JSMessage.h"
#import "ConnectionProvider.h"
#import "ImageManager.h"
#import "RNBlurModalView.h"
#import "ChatDBManager.h"
#import "StyleManager.h"
#import "FriendsDBManager.h"
#import "FriendMO.h"
#import "AddToGroupViewController.h"
#import "IQPacketManager.h"
#import "JSBubbleMessageCell.h"
#import "UserDefaultManager.h"
#import "UIScrollView+GifPullToRefresh.h"

@interface ConversationViewController ()

@property (strong, nonatomic) ConnectionProvider *cp;
@property (strong, nonatomic) CustomIOS7AlertView *reportAlertView;

@end

@implementation ConversationViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self discloseInfoButtonClicked:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLongPress:) name:NOTIFICATION_DID_LONG_PRESS_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatMO:) name:PACKET_ID_GET_CHAT_PARTICIPANTS object:nil];
    
    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetChatParticipantsPacket:_chatMO.chat_id]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[StyleManager getColorBlue]];
    
    self.delegate = self;
    self.dataSource = self;
    self.im = [[ImageManager alloc] init];
    [self.im setDelegate:self];
    self.downloadingImageURLs = [[NSMutableArray alloc] initWithCapacity:20];
    [self.headerLabel setText:[self.chatMO getChatName]];
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [self.participantsLabel setFont:[StyleManager getFontStyleLightSizeMed]];
    [self.participantsLabel setTextColor:[StyleManager getColorBlue]];
    
    _reportAlertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Bullying", @"Self Harm", @"Spam", @"Inappropriate", @"Cancel", nil]];
    [_reportAlertView setDelegate:self];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, 62.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:headerBottomborder];
    
    [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
    
    [self setUpPullToLoad];
    
    // HEADER IS CHANGING SIZE! WHYYYYY
    _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, 62.0f);
    [self.view bringSubviewToFront:_participantsView];
    [self.view bringSubviewToFront:_header];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showParticipantsAlert)];
    [_participantsView addGestureRecognizer:gesture];
}

-(void)setUpPullToLoad {
    NSMutableArray *drawingImages = [NSMutableArray array];
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [drawingImages addObject:[UIImage imageNamed:fileName]];
    }
    
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [loadingImages addObject:[UIImage imageNamed:fileName]];
    }
    [self.tableView addPullToRefreshWithDrawingImgs:drawingImages andLoadingImgs:loadingImages andActionHandler:^{
        [self performSelectorOnMainThread:@selector(loadMoreMessages) withObject:nil waitUntilDone:NO];
    }];
}

-(void)updateChatMO:(NSNotification *)notification {
    NSMutableArray *participants = [[notification userInfo] objectForKey:PACKET_ID_GET_CHAT_PARTICIPANTS];
    [_chatMO setParticipants:participants];
}

-(void)loadMoreMessages {
    if ([_chatMO.messages count] == 0) {
        [self didFinishLoadingMoreMessages];
    } else {
        NSArray *messages = [MessagesDBManager getMessagesByChat:_chatMO.chat_id since:[_chatMO.messages firstObject]];
        NSMutableArray *new = [[NSMutableArray alloc] initWithCapacity:[_chatMO.messages count] + [messages count]];
        [new addObjectsFromArray:messages];
        [new addObjectsFromArray:_chatMO.messages];
        [_chatMO setMessages:new];
        [self didFinishLoadingMoreMessages];
    }
}

-(void)didFinishLoadingMoreMessages {
    [self.tableView didFinishPullToRefresh];
    [self.tableView reloadData];
}

-(void)handleLongPress:(NSNotification *)notification
{
    UILongPressGestureRecognizer *gestureRecognizer = [notification.userInfo objectForKey:NOTIFICATION_DID_LONG_PRESS_MESSAGE];
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
    }
    else {
        [self handleLongPressForRowAtIndexPath:indexPath];
    }
}

-(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    MessageMO *mesage =[[_chatMO messages] objectAtIndex:indexPath.row];
    
    if ([[mesage sender_id] isEqualToString:[ConnectionProvider getUser]]) return;
    
    _messageToBlock = mesage;
    _blockIndexPath = indexPath;
    
    /*UIAlertView *reportAbuse = [[UIAlertView alloc] initWithTitle:@"Block" message: @"Do you want to block the sender?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:REPORT_BLOCK, nil];
     
     reportAbuse.alertViewStyle = UIAlertViewStyleDefault;*/
    
    //CustomIOS7AlertView *reportAbuse = [StyleManager createCustomAlertView:@"Block" message:@"Do you want to block the sender?" buttons:[NSMutableArray arrayWithObjects:@"Cancel", REPORT_BLOCK, nil] hasInput:NO];
    CustomIOS7AlertView *reportAbuse = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Block User", @"Report Message", @"Cancel", nil]];
    [reportAbuse setDelegate:self];
    [reportAbuse show];
    [self.view endEditing:YES];
}

-(void)participantsUpdated:(NSNotification *)notification {
    self.chatMO = [ChatDBManager getChatWithID:self.chatMO.chat_id];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatMO getNumberOfMessages];
}

-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    MessageMO *newMessage = [userInfo objectForKey:DICTIONARY_KEY_MESSAGE_OBJECT];
    if ([newMessage.group_id isEqualToString:self.chatMO.chat_id]) {
        [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
        if ([newMessage.sender_id isEqualToString:[ConnectionProvider getUser]]) {
            [self.chatMO updateMessage:newMessage];
        } else {
            NSLog(@"Table Before: %d", [self.tableView numberOfRowsInSection:0]);
            [self.tableView reloadData];
            [self scrollToBottomAnimated:YES];
            NSLog(@"Table After: %d", [self.tableView numberOfRowsInSection:0]);
            /*NSLog(@"Previous In Table: %d", [self.tableView numberOfRowsInSection:0]);
            if([self.chatMO getNumberOfMessages] > 1) {
             [self animateAddNewestMessageAtRow:10];
             } else {
             [self.tableView reloadData];
             }*/
        }
    }
}

-(void)animateAddNewestMessageAtRow:(int)row {
    NSLog(@"Messages in Chat: %d", [_chatMO getNumberOfMessages]);
    
    for (MessageMO *message in _chatMO.messages) {
        NSLog(@"=============== %@", message.message_body);
    }
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row-1 inSection:0];
    NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
    NSLog(@"Index Path Row: %d", indexPath.row);
    
    /*NSMutableArray *deleteArr = [[NSMutableArray alloc] init];
    for (int i=0; i<([self.tableView numberOfRowsInSection:0] - 10); i++) {
        NSIndexPath *deletePath = [NSIndexPath indexPathForRow:i inSection:0];
        [deleteArr addObject:deletePath];
        NSLog(@"To delete: %d", i);
    }*/
    
    [self.tableView beginUpdates];
    //[self.tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    [self scrollToBottomAnimated:YES];
    self.messageImage = nil;
    self.messageImageLink = nil;
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageMO *message = [[_chatMO messages] objectAtIndex:indexPath.row];
    if ([message.sender_id isEqualToString:[ConnectionProvider getUser]]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageMO *messageMO = [[_chatMO messages] objectAtIndex:indexPath.row];
    NSDate *date;
    if(messageMO.time != nil) {
        date = [NSDate dateWithTimeIntervalSince1970: [messageMO.time doubleValue]];
    } else {
        date = [NSDate date];
    }
    JSMessage *jmessage = [[JSMessage alloc] initWithText:messageMO.message_body sender:@"" date:date];
    return jmessage;
}

-(MessageMO *)messageMOForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_chatMO messages] objectAtIndex:indexPath.row];
}

-(MessageMO *)prevMessageMOForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_chatMO messages] objectAtIndex:indexPath.row - 1];
}

-(MessageMO *)twoPrevMessageMOForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[_chatMO messages] objectAtIndex:indexPath.row - 2];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedImage = [[self avatarImageViewForRowAtIndexPath:indexPath sender:@""] image];
    if (self.selectedImage != nil) {
        [self.view endEditing:YES];
        CGFloat imageAspectRatio = self.selectedImage.size.height / self.selectedImage.size.width,
        screenAspectRatio = self.view.frame.size.height / self.view.frame.size.width,
        imageWidth = 0.0,
        imageHeight = 0.0;
        
        if (imageAspectRatio > screenAspectRatio) {
            imageHeight = self.view.frame.size.height - 70;
            imageWidth = imageHeight / imageAspectRatio;
        } else {
            imageWidth = self.view.frame.size.width - 70;
            imageHeight = imageWidth * imageAspectRatio;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x , self.view.frame.origin.y, imageWidth, imageHeight)];
        [imageView setImage:self.selectedImage];
        RNBlurModalView *modal = [[RNBlurModalView alloc] initWithViewController:self view:imageView];
        [modal show];
    }
}

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.bubbleView.textView.textColor = [UIColor blackColor];
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor whiteColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor blackColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor blackColor]];
    }
}

-(JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    MessageMO *message = [self.chatMO.messages objectAtIndex:indexPath.row];
    ImageCache *imageCache = [ImageCache getInstance];
    UIImage *image;
    if (message.image_link == nil) {
        return nil;
    } else if((image = [imageCache getImageWithIdentifier:message.image_link]) != nil) {
        return [[UIImageView alloc] initWithImage:image];
    } else if(![self.downloadingImageURLs containsObject:message.image_link]) {
        [self.im downloadImageForMessage:message delegate:self];
        [self.downloadingImageURLs addObject:message.image_link];
    }
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    return emptyImageView;
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if (self.isUploadingImage == YES) {
        //[[[UIAlertView alloc] initWithTitle:@"Hold on..." message:@"Wait just a sec, we are still loading your picture." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        
        CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Hold on..." message:@"Wait just a sec, we are still loading your picture." buttons:[NSMutableArray arrayWithObject:@"Ok"] hasInput:NO];
        [alertView setDelegate:self];
        [alertView show];
        
        return;
    }
    if (self.messageImageLink == nil && (text == nil || [text isEqualToString:@""])) {
        return;
    }
    NSLog(@"Previous Number of Messages: %d", [_chatMO getNumberOfMessages]);
    NSLog(@"Previous In Table: %d", [self.tableView numberOfRowsInSection:0]);
    [self resetCameraButtonImage];
    [self.chatMO sendMUCMessageWithBody:text imageLink:self.messageImageLink];
    [self animateAddNewestMessageAtRow:[self.tableView numberOfRowsInSection:0]];
    [self finishSend];
}

-(void)didSelectImage:(UIImage *)image {
    self.isUploadingImage = YES;
    [_im uploadImageToGCS:image delegate:self bucket:BUCKET_MESSAGES];
}

-(void)didFinishDownloadingImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    NSLog(@"Finished downloading image: %@", identifier);
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

-(void)didFailToDownloadImageWithIdentifier:(NSString *)identifier {
    NSLog(@"Failed to download image");
}

-(void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url withError:(NSError *)error {
    NSLog(@"Failed to upload image");
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    NSLog(@"Finished uploading image");
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

- (IBAction)onBackClicked:(id)sender {
    [ChatDBManager setHasNewMessageNo:_chatMO.chat_id];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)discloseInfoButtonClicked:(id)sender {
    if (_participantsView.frame.origin.y < _header.frame.size.height) {
        [self showParticipantsView];
    } else {
        [self hideParticipantsView];
    }
}

- (void)showParticipantsView {
    [_participantsLabel setText:[self getParticipantString]];
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:3.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat shiftAmount = 39;
                         CGRect tbFrame = self.tableView.frame;
                         self.tableView.frame = CGRectMake(tbFrame.origin.x, tbFrame.origin.y + shiftAmount, tbFrame.size.width, tbFrame.size.height - shiftAmount);
                         _participantsView.frame = CGRectMake(0, _participantsView.frame.origin.y + shiftAmount, _participantsView.frame.size.width, _participantsView.frame.size.height);
                     } completion: nil];
}

- (void)hideParticipantsView {
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:3.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat shiftAmount = _participantsView.frame.size.height;
                         NSLog(@"Shift Amount: %f", shiftAmount);
                         CGRect tbFrame = self.tableView.frame;
                         self.tableView.frame = CGRectMake(tbFrame.origin.x, tbFrame.origin.y - shiftAmount, tbFrame.size.width, tbFrame.size.height + shiftAmount);
                         _participantsView.frame = CGRectMake(0, _participantsView.frame.origin.y - shiftAmount, _participantsView.frame.size.width, _participantsView.frame.size.height);
                     } completion:nil];
}

- (IBAction)participantsInfoBtnAction:(id)sender {
    [self.view endEditing:YES];
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:_headerLabel.text message:@"This is a group chat. Everyone knows who is in the group, but no one knows who is sending each message." buttons:[NSMutableArray arrayWithObjects:@"Got it", @"Add Friends", nil] hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Got it"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ok"]) {
        [alertView close];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Friends"]) {
        [alertView close];
        [self performSegueWithIdentifier:SEGUE_ID_ADD_TO_GROUP sender:self];
    } else if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:REPORT_BLOCK]) {
        if (_messageToBlock != nil) {
            [[self.cp getConnection] sendElement:[IQPacketManager createBlockUserInGroupPacket:_messageToBlock.sender_id chatID:_chatMO.chat_id]];
            [_messageToBlock setMessage_body:@"Message from blocked user"];
            [self.tableView reloadData];
        }
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report Message"]) {
        [_reportAlertView show];
        [alertView close];
    } else if (alertView == _reportAlertView) {
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            //Remove message bubble after message animations are fixed. Now the bubble shows (without text) until the chat is reopened.
            //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_blockIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createReportMessageInGroupPacket:_chatMO.chat_id type:[[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"] message:_messageToBlock]];
            [MessagesDBManager deleteMessageFrom:_messageToBlock.sender_id body:_messageToBlock.message_body time:_messageToBlock.time];
            [ChatDBManager setHasNewMessageNo:_chatMO.chat_id];
            [self.tableView reloadData];
            _blockIndexPath = nil;
            _messageToBlock = nil;
        }
        [alertView close];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_ID_ADD_TO_GROUP]) {
        id destination = segue.destinationViewController;
        if ([destination conformsToProtocol:@protocol(AddToGroupViewController)]) {
            [destination setChatID:_chatMO.chat_id];
        }
    }
}

- (NSString *)getParticipantString {
    NSArray *members = _chatMO.participants;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *memberUsername, *invitedBy;
    for (NSDictionary *member in members) {
        memberUsername = [member objectForKey:PARTICIPANT_USERNAME];
        invitedBy = [member objectForKey:PARTICIPANT_INVITED_BY];
        if ([memberUsername isEqualToString:[ConnectionProvider getUser]]) {
            continue;
        }
        FriendMO *friend = [FriendsDBManager getUserWithJID:memberUsername];
        if (friend == nil) {
            FriendMO *invitedByFriend = [FriendsDBManager getUserWithJID:invitedBy];
            if (invitedByFriend == nil || invitedByFriend.name == nil) {
                [list addObject:[NSString stringWithFormat:@"%@ (Friend of Friend)", memberUsername]];
            } else {
                [list addObject:[NSString stringWithFormat:@"%@ (Friend of %@)", memberUsername, [[invitedByFriend.name componentsSeparatedByString:@" "] firstObject]]];
            }
        } else {
            [list addObject:[[friend.name componentsSeparatedByString:@" "] firstObject]];
        }
    }
    NSString *participantString;
    if ([list count] == 0) {
        participantString = @"Hmm... This chat is empty";
    } else {
        participantString = [NSString stringWithFormat:@"Group: %@", [list componentsJoinedByString:@", "]];
    }
    return participantString;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] == buttonIndex) {
        return;
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Add Users"]) {
        [self performSegueWithIdentifier:SEGUE_ID_ADD_TO_GROUP sender:self];
    } else if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:REPORT_BLOCK]) {
        if (_messageToBlock != nil) {
            [[self.cp getConnection] sendElement:[IQPacketManager createBlockUserInGroupPacket:_messageToBlock.sender_id chatID:_chatMO.chat_id]];
            [_messageToBlock setMessage_body:@"Message from blocked user"];
            [self.tableView reloadData];
        }
    } else {
        _messageToBlock = nil;
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)showParticipantsAlert {
    [[StyleManager createCustomAlertView:@"Group Participants" message:[_participantsLabel.text substringFromIndex:6] buttons:@[@"Got it"] hasInput:NO] show];
}

/*-(BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
 MessageMO *message = [self messageMOForRowAtIndexPath:indexPath];
 MessageMO *prevMessage = [[_chatMO messages] objectAtIndex:indexPath.row - 1];
 MessageMO *twoPrevMessage = [[_chatMO messages] objectAtIndex:indexPath.row - 1];
 if (prevMessage == nil || twoPrevMessage == nil) {
 return YES;
 }
 
 if([message.time doubleValue] - [prevMessage.time doubleValue] > 5000 || [self shouldDisplayTimestampForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:indexPath.row - 2]] == NO) {
 return YES;
 }
 return NO;
 }*/

@end
