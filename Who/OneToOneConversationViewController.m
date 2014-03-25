//
//  OneToOneConversationViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneConversationViewController.h"
#import "Constants.h"
#import "JSMessage.h"
#import "ConnectionProvider.h"
#import "RNBlurModalView.h"
#import "ChatDBManager.h"
#import "MessageMO.h"
#import "ChatMO.h"
#import "StyleManager.h"

@implementation OneToOneConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    
    [self.tableView setBackgroundColor:[StyleManager getColorBlue]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.delegate = self;
    self.dataSource = self;
    self.im = [[ImageManager alloc] init];
    [self.im setDelegate:self];
    self.imageCache = [ImageCache getInstance];
    self.downloadingImageURLs = [[NSMutableArray alloc] initWithCapacity:20];
    [self.headerLabel setText:[self.chatMO user_defined_chat_name]];
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, self.header.frame.size.height - 2.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.header.layer addSublayer:headerBottomborder];
    
    [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
}

-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSString*)[userInfo objectForKey:MESSAGE_PROPERTY_GROUP_ID] compare:self.chatMO.chat_id] == 0) {
        if([self.chatMO getNumberOfMessages] <= 1) {
            [ChatDBManager setHasNewMessageNo:self.chatMO.chat_id];
            [self.tableView reloadData];
        } else {
            [self animateAddNewestMessage];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedImage = [[self avatarImageViewForRowAtIndexPath:indexPath sender:@""] image];
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

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageMO * message = [self.chatMO.messages objectAtIndex:indexPath.row];
    if ([message.sender_id compare:[ConnectionProvider getUser]] == 0) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageMO *message = [self.chatMO.messages objectAtIndex:indexPath.row];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [message.time doubleValue]];
    JSMessage *jmessage = [[JSMessage alloc] initWithText:message.message_body sender:@"" date:date];
    return jmessage;
}

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.bubbleView.textView.textColor = [UIColor blackColor];
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor whiteColor];
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

-(void)animateAddNewestMessage {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.chatMO getNumberOfMessages] - 1 inSection:0];
    NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
    [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationFade];
    [self scrollToBottomAnimated:YES];
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    NSLog(@"Chat Participants: %@", self.chatMO.participant_string);
    
    while (self.isUploadingImage == YES);
    NSLog(@"Chat Size: %u", [self.chatMO getNumberOfMessages]);
    NSLog(@"Current ChatMO: %@", [self.chatMO description]);
    [self.chatMO sendOneToOneMessage:text imageLink:self.messageImageLink];
    
    self.messageImage = nil;
    self.messageImageLink = nil;
    [self animateAddNewestMessage];
    [self finishSend];
}


-(void)didSelectImage:(UIImage *)image {
    NSLog(@"Image: %@", [image description]);
    self.isUploadingImage = YES;
    [self.im uploadImage:image url:@"http://media.versapp.co"];
}

-(void)didFinishDownloadingImage:(UIImage *)image fromURL:(NSString *)url forMessage:(MessageMO *)message {
    [self.tableView reloadData];
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    NSLog(@"Did finish Uploading Image: %@ to url %@", [image description], url);
    self.isUploadingImage = NO;
    self.messageImage = image;
    self.messageImageLink = url;
}

- (IBAction)onBackClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
