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
#import <QuartzCore/QuartzCore.h>
#import "JSMessage.h"
#import "ConnectionProvider.h"
#import "ImageManager.h"
@interface ConversationViewController ()

@end

@implementation ConversationViewController

@synthesize gc;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Current GC: %@", [self.gc description]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    self.navigationItem.title = self.gc.name;
    self.delegate = self;
    self.dataSource = self;
    //[self.conversationTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.gc getNumberOfMessages];
}

-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSString*)[userInfo objectForKey:MESSAGE_PROPERTY_GROUP_ID] compare:self.gc.chatID] == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.gc.getNumberOfMessages - 1 inSection:0];
        NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];
        [self scrollToBottomAnimated:YES];
    }
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.gc getMessageByIndex:indexPath.row];
    NSLog(@"Message Sender: %@", message.sender);
    NSLog(@"User: %@", [ConnectionProvider getUser]);
    if ([message.sender compare:[ConnectionProvider getUser]] == 0) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.gc getMessageByIndex:indexPath.row];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [message.timestamp doubleValue]];
    JSMessage *jmessage = [[JSMessage alloc] initWithText:message.body sender:@"" date:date];
    return jmessage;
}

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleBlueColor]];
    }
}

-(JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return nil;
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    while (self.isUploadingImage == YES);
    if (self.messageImageLink != nil) {
        [self.gc sendMUCMessage:text imageLink:self.messageImageLink];
        self.messageImage = nil;
        self.messageImageLink = nil;
    } else {
        [self.gc sendMUCMessage:text];
    }
    [self finishSend];
}

-(void)didSelectImage:(UIImage *)image {
    self.isUploadingImage = YES;
    ImageManager *im = [[ImageManager alloc] init];
    [im setDelegate:self];
    [im uploadImage:image url:[NSString stringWithFormat:@"http://%@", [ConnectionProvider getServerIPAddress]]];
}

-(void)didFinishDownloadingImage:(UIImage *)image fromURL:(NSString *)url forMessage:(Message *)message {
    
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

@end
