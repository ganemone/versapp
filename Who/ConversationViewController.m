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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceived:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    self.navigationItem.title = self.gc.name;
    self.originalCenter = self.view.center;

    [self.conversationTableView setDelegate:self];
    [self.conversationTableView setDataSource:self];
    [self.messageTextField setDelegate:self];
    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gc getNumberOfMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_CONVERSATION_PROTOTYPE forIndexPath:indexPath];
    NSString *text = [self.gc getMessageTextByIndex:indexPath.row];
    cell.textLabel.text = text;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellText = [self.gc getMessageTextByIndex:indexPath.row];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 20;
}

-(void)messageReceived:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    if ([(NSString*)[userInfo objectForKey:MESSAGE_PROPERTY_GROUP_ID] compare:self.gc.chatID] == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.gc.getNumberOfMessages inSection:0];
        NSArray *indexPathArr = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.conversationTableView reloadRowsAtIndexPaths:indexPathArr withRowAnimation:UITableViewRowAnimationBottom];
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
