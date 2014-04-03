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

@interface ConversationViewController ()

@property (strong, nonatomic) ConnectionProvider *cp;

@end

@implementation ConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    
    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetChatParticipantsPacket:_chatMO.chat_id]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[StyleManager getColorBlue]];
    
    self.delegate = self;
    self.dataSource = self;
    self.im = [[ImageManager alloc] init];
    [self.im setDelegate:self];
    self.imageCache = [ImageCache getInstance];
    self.downloadingImageURLs = [[NSMutableArray alloc] initWithCapacity:20];
    [self.headerLabel setText:[self.chatMO getChatName]];
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    //UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
    //                                    initWithTarget:self action:@selector(handleLongPress:)];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, 62.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:headerBottomborder];
    
    [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
}
/*
 -(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
 {
 if (gestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
 return;
 
 CGPoint p = [gestureRecognizer locationInView:self.tableView];
 NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
 if (indexPath == nil) {
 NSLog(@"long press on table view but not on a row");
 }
 else {
 NSLog(@"long press on table view at row %d", indexPath.row);
 [self handleLongPressForRowAtIndexPath:indexPath];
 }
 }
 
 -(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
 
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Conversation" message:@"Enter a new name for this conversation." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
 [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
 [alertView show];
 
 }*/

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
    if ([newMessage.group_id compare:self.chatMO.chat_id] == 0) {
        [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
        if ([newMessage.sender_id compare:[ConnectionProvider getUser]] == 0) {
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
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageMO *messageMO = [[_chatMO messages] objectAtIndex:indexPath.row];
    if ([messageMO.sender_id compare:[ConnectionProvider getUser]] == 0) {
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedImage = [[self avatarImageViewForRowAtIndexPath:indexPath sender:@""] image];
    if (self.selectedImage != nil) {
        
        CGFloat imageAspectRatio = self.selectedImage.size.height / self.selectedImage.size.width,
        screenAspectRatio = self.view.frame.size.height / self.view.frame.size.width,
        imageWidth = 0.0,
        imageHeight = 0.0;
        
        if (imageAspectRatio > screenAspectRatio) {
            NSLog(@"Image Aspect Ratio Greater than Screen");
            imageHeight = self.view.frame.size.height - 70;
            imageWidth = imageHeight / imageAspectRatio;
        } else {
            NSLog(@"Image Aspect Ratio Less than Screen");
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
    UIImage *image;
    if (message.image_link == nil) {
        return nil;
    } else if((image = [self.imageCache getImageByMessageSender:message.sender_id timestamp:message.time]) != nil) {
        return [[UIImageView alloc] initWithImage:image];
    } else if(![self.downloadingImageURLs containsObject:message.image_link]) {
        [self.im downloadImageForMessage:message];
        [self.downloadingImageURLs addObject:message.image_link];
    }
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    return emptyImageView;
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    while (self.isUploadingImage == YES);
    [self resetCameraButtonImage];
    [self.chatMO sendMUCMessageWithBody:text imageLink:self.messageImageLink];
    self.messageImage = nil;
    self.messageImageLink = nil;
    [self animateAddNewestMessage];
    [self finishSend];
}

-(void)didSelectImage:(UIImage *)image {
    self.isUploadingImage = YES;
    [self.im uploadImage:image url:@"http://media.versapp.co"];
}

-(void)didFinishDownloadingImage:(UIImage *)image fromURL:(NSString *)url forMessage:(MessageMO *)message {
    NSLog(@"Reached Delegate Method");
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)discloseInfoButtonClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_headerLabel.text message:@"This is a group chat. Everyone knows who is in the group, but no one knows who is sending each message." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier compare:SEGUE_ID_ADD_TO_GROUP] == 0) {
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
    NSString *participantString = [list componentsJoinedByString:@"\n"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.headerLabel.text message:participantString delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Add Users", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView numberOfButtons] == 1) {
        return;
    }
    if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Add Users"]) {
        if (!(buttonIndex == [alertView cancelButtonIndex])) {
            [self performSegueWithIdentifier:SEGUE_ID_ADD_TO_GROUP sender:self];
        }
    } else {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

@end
