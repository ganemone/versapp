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
@interface ConversationViewController ()

@end

@implementation ConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    
    UIImage *image = [UIImage imageNamed:@"grad-back-dark2.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setImage:image];
    
    [self.tableView setBackgroundView:backgroundImageView];
    [self.tableView setBackgroundColor:nil];
    [self.tableView setOpaque:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.navigationItem.title = self.gc.name;
    self.delegate = self;
    self.dataSource = self;
    self.im = [[ImageManager alloc] init];
    [self.im setDelegate:self];
    self.imageCache = [ImageCache getInstance];
    self.downloadingImageURLs = [[NSMutableArray alloc] initWithCapacity:20];
    
    [ChatDBManager setHasNewMessageNo:self.gc.chatID];
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
    NSLog(@"Received Message! :%@", [newMessage message_body]);
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
    cell.bubbleView.textView.textColor = [UIColor whiteColor];
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
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
    return nil;
    //    if (message.image_link == nil) {
    //        return nil;
    //    } else if((image = [self.imageCache getImageByMessageSender:message.sender timestamp:message.timestamp]) != nil) {
    //        return [[UIImageView alloc] initWithImage:image];
    //    } else if(![self.downloadingImageURLs containsObject:message.image_link]) {
    //        [self.im downloadImageForMessage:message];
    //        [self.downloadingImageURLs addObject:message.image_link];
    //    }
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    return emptyImageView;
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    while (self.isUploadingImage == YES);
    [self.chatMO sendMUCMessageWithBody:text imageLink:self.messageImageLink];
    self.messageImage = nil;
    self.messageImageLink = nil;
    [self animateAddNewestMessage];
    [self finishSend];
}

-(void)didSelectImage:(UIImage *)image {
    self.isUploadingImage = YES;
    [self.im uploadImage:image url:[NSString stringWithFormat:@"http://%@", [ConnectionProvider getServerIPAddress]]];
}

-(void)didFinishDownloadingImage:(UIImage *)image fromURL:(NSString *)url forMessage:(Message *)message {
    NSLog(@"Reached Delegate Method");
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

@end
