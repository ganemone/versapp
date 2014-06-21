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

@end

@implementation ConversationViewController

-(void)viewDidAppear:(BOOL)animated {
    if ([UserDefaultManager hasCreatedGroup] == NO) {
        [UserDefaultManager setCreatedGroupTrue];
        [self discloseInfoButtonClicked:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLongPress:) name:NOTIFICATION_DID_LONG_PRESS_MESSAGE object:nil];
    
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
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, 62.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:headerBottomborder];
    
    [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
    
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
    
    UIAlertView *reportAbuse = [[UIAlertView alloc] initWithTitle:@"Block" message: @"Do you want to block the sender?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:REPORT_BLOCK, nil];
    
    reportAbuse.alertViewStyle = UIAlertViewStyleDefault;
    [reportAbuse show];
    
}

-(void)participantsUpdated:(NSNotification *)notification {
    self.chatMO = [ChatDBManager getChatWithID:self.chatMO.chat_id];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
            if([self.chatMO getNumberOfMessages] <= 1) {
                [self.tableView reloadData];
            } else {
                [self animateAddNewestMessage];
            }
        }
    }
}

-(void)animateAddNewestMessage {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatMO getNumberOfMessages] - 1 inSection:0];
    NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];
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
        [[[UIAlertView alloc] initWithTitle:@"Hold on..." message:@"Wait just a sec, we are still loading your picture." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    if (self.messageImageLink == nil && (text == nil || [text isEqualToString:@""])) {
        return;
    }
    [self resetCameraButtonImage];
    [self.chatMO sendMUCMessageWithBody:text imageLink:self.messageImageLink];
    [self animateAddNewestMessage];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_headerLabel.text message:@"This is a group chat. Everyone knows who is in the group, but no one knows who is sending each message." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_ID_ADD_TO_GROUP]) {
        id destination = segue.destinationViewController;
        if ([destination conformsToProtocol:@protocol(AddToGroupViewController)]) {
            [destination setChatID:_chatMO.chat_id];
        }
    }
}

- (IBAction)showGroupParticipants:(id)sender {
    _chatMO = [ChatDBManager getChatWithID:_chatMO.chat_id];
    NSArray *members = self.chatMO.participants;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (NSString *member in members) {
        FriendMO *friend = [FriendsDBManager getUserWithJID:[NSString stringWithFormat:@"%@", member]];
        if (friend == nil) {
            NSString *name = [[[ConnectionProvider getInstance] tempVCardInfo] objectForKey:member];
            if (name != nil) {
                [list addObject:name];
            }
        } else {
            [list addObject:friend.name];
        }
    }
    NSString *participantString;
    if ([list count] == 0) {
        participantString = @"No one has joined this chat just yet.";
    } else {
        participantString = [list componentsJoinedByString:@"\n"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.headerLabel.text message:participantString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Add Users", nil];
    [alert show];
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
