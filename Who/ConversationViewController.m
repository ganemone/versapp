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
@interface ConversationViewController ()

@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property CGPoint originalCenter;

@end

@implementation ConversationViewController

@synthesize gc;
@synthesize conversationTableView;
@synthesize messageTextField;
@synthesize cameraButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Current GC: %@", [self.gc description]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    self.navigationItem.title = self.gc.name;
    self.originalCenter = self.view.center;
    self.delegate = self;
    self.dataSource = self;
    [self.conversationTableView setDelegate:self];
    [self.conversationTableView setDataSource:self];
    [self.messageTextField setDelegate:self];
    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
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
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_CONVERSATION_PROTOTYPE forIndexPath:indexPath];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    NSString *text = [self.gc getMessageTextByIndex:indexPath.row];
    cell.textLabel.text = text;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellText = [self.gc getMessageTextByIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 10;
}
*/
-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSString*)[userInfo objectForKey:MESSAGE_PROPERTY_GROUP_ID] compare:self.gc.chatID] == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.gc.getNumberOfMessages - 1 inSection:0];
        NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.conversationTableView insertRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationLeft];
    }
}
-(void)keyboardDidShow:(NSNotification*)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    NSDictionary *info = notification.userInfo;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.view setCenter:CGPointMake(self.view.center.x, self.view.center.y - kbSize.height)];
    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.messageTextField.returnKeyType = UIReturnKeySend;
    } else {
        self.messageTextField.returnKeyType = UIReturnKeyDone;
    }
    [self.messageTextField reloadInputViews];
}

-(void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        self.messageTextField.returnKeyType = UIReturnKeySend;
    } else {
        self.messageTextField.returnKeyType = UIReturnKeyDone;
    }
    [self.messageTextField reloadInputViews];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(self.messageTextField.returnKeyType == UIReturnKeySend) {
        [self sendMUCMessage];
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    [self.view setCenter:self.originalCenter];
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

-(void)sendMUCMessage {
    [self.gc sendMUCMessage:self.messageTextField.text];
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
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [message.timestamp doubleValue]];
    JSMessage *jmessage = [[JSMessage alloc] initWithText:message.body sender:@"Sender..." date:date];
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
    if (indexPath.row % 2) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

-(JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    UIImageView *image = [[UIImageView alloc] init];
    return image;
}

-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    NSLog(@"Did send text...");
}



@end
