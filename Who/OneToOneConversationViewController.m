//
//  OneToOneConversationViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneConversationViewController.h"
#import "Constants.h"
#import "Message.h"
#import "JSMessage.h"
#import "ConnectionProvider.h"


@implementation OneToOneConversationViewController

@synthesize chat;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    
    self.navigationItem.title = self.chat.name;
    self.delegate = self;
    self.dataSource = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSString*)[userInfo objectForKey:MESSAGE_PROPERTY_GROUP_ID] compare:self.chat.chatID] == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chat.getNumberOfMessages - 1 inSection:0];
        NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationBottom];
        [self scrollToBottomAnimated:YES];
    }
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
    return [self.chat getNumberOfMessages];
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    [self.chat sendOneToOneMessage:text messageTo:[self.chat getMessageTo]];
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.chat getMessageByIndex:indexPath.row];
    if ([message.sender compare:[ConnectionProvider getUser]] == 0) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message * message = [self.chat getMessageByIndex:indexPath.row];
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
