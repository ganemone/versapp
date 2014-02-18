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
#import "ConversationImageExpandViewController.h"
#import "RNBlurModalView.h"

@interface ConversationViewController ()

@end

@implementation ConversationViewController

@synthesize gc;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier compare:SEGUE_ID_GROUP_VIEW_IMAGE] == 0) {
        NSLog(@"Setting image on controller....");
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.gc.name style:UIBarButtonItemStylePlain target:nil action:nil];
        ConversationImageExpandViewController *dest = segue.destinationViewController;
        [dest setSelectedImage:self.selectedImage];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    self.navigationItem.title = self.gc.name;
    self.delegate = self;
    self.dataSource = self;
    
    self.im = [[ImageManager alloc] init];
    [self.im setDelegate:self];
    
    self.imageCache = [ImageCache getInstance];
    
    self.downloadingImageURLs = [[NSMutableArray alloc] initWithCapacity:20];
    
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
        [self animateAddNewestMessage];
    }
}

-(void)animateAddNewestMessage {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.gc.getNumberOfMessages - 1 inSection:0];
    NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];
    [self scrollToBottomAnimated:YES];
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.gc getMessageByIndex:indexPath.row];
    if ([message.sender compare:[ConnectionProvider getUser]] == 0) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.gc getMessageByIndex:indexPath.row];
    NSDate *date;
    if(message.timestamp != nil) {
        date = [NSDate dateWithTimeIntervalSince1970: [message.timestamp doubleValue]];
    } else {
        date = [NSDate date];
    }
    JSMessage *jmessage = [[JSMessage alloc] initWithText:message.body sender:@"" date:date];
    return jmessage;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedImage = [[self avatarImageViewForRowAtIndexPath:indexPath sender:@""] image];
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
    
    //[self performSegueWithIdentifier:SEGUE_ID_GROUP_VIEW_IMAGE sender:self];
}

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor blackColor];
        /*if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }*/
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    /*if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }*/
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (type == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleGreenColor]];
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
    Message *message = [self.gc getMessageByIndex:indexPath.row];
    UIImage *image;
    if (message.imageLink == nil) {
        return nil;
        NSLog(@"No Avatar");
    } else if((image = [self.imageCache getImageByMessageSender:message.sender timestamp:message.timestamp]) != nil) {
        return [[UIImageView alloc] initWithImage:image];
        NSLog(@"Returning image from cache");
    } else if(![self.downloadingImageURLs containsObject:message.imageLink]) {
        [self.im downloadImageForMessage:message];
        [self.downloadingImageURLs addObject:message.imageLink];
    }
    UIImageView *emptyImageView = [[UIImageView alloc] init];
    return emptyImageView;
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
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

@end
