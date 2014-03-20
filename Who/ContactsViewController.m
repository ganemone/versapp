//
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddressBook/AddressBook.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ContactSearchManager.h"
#import "FriendsDBManager.h"
#import "StyleManager.h"
#import "ContactTableViewCell.h"
#import "AppDelegate.h"

@interface ContactsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *registeredContacts;
@property (strong, nonatomic) NSArray *unregisteredContacts;
@property (strong, nonatomic) NSMutableArray *selectedRegisteredContacts;
@property (strong, nonatomic) NSMutableArray *selectedUnregisteredContacts;
@property (strong, nonatomic) NSMutableArray *smsContacts;
@property (strong, nonatomic) NSMutableArray *emailContacts;

@end

@implementation ContactsViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[StyleManager getColorGreen]];
    [self.tableView setBackgroundColor:[StyleManager getColorGreen]];
    
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [self.footerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, self.header.frame.size.height - 2.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.header.layer addSublayer:headerBottomborder];
    
    self.registeredContacts = [FriendsDBManager getAllWithStatusRegisteredOrRequested];
    self.unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    self.selectedRegisteredContacts = [[NSMutableArray alloc] initWithCapacity:[_registeredContacts count]];
    self.selectedUnregisteredContacts = [[NSMutableArray alloc] initWithCapacity:[_unregisteredContacts count]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UPDATE_CONTACTS_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:PACKET_ID_GET_VCARD object:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactsTableViewCell";
    FriendMO *friend = (indexPath.section == 0) ? [_registeredContacts objectAtIndex:indexPath.row] : [_unregisteredContacts objectAtIndex:indexPath.row];
    ContactTableViewCell *cell = [[ContactTableViewCell alloc] initWithFriend:friend reuseIdentifier:CellIdentifier];
    [cell.actionBtn addTarget:self action:@selector(handleActionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [_registeredContacts count] : [_unregisteredContacts count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Versappers in your Contacts" : @"Invite to Versapp";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)refreshData {
    _registeredContacts = [FriendsDBManager getAllWithStatusRegisteredOrRequested];
    _unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    [self.tableView reloadData];
}

- (IBAction)backArrowClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionReverse], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_FRIENDS
                                                        object:nil
                                                      userInfo:userInfo];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleRowSelectedAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)handleActionBtnClicked:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    [self handleRowSelectedAtIndexPath:indexPath];
}

- (void)handleRowSelectedAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = (ContactTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    FriendMO *friend = [self friendForIndexPath:indexPath];
    
    if ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_REGISTERED]]) {
        if ([_selectedRegisteredContacts containsObject:friend]) {
            [_selectedRegisteredContacts removeObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select.png"] forState:UIControlStateNormal];
        } else {
            [_selectedRegisteredContacts addObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-active.png"] forState:UIControlStateNormal];
        }
    } else if([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_UNREGISTERED]]) {
        if ([_selectedUnregisteredContacts containsObject:friend]) {
            [_selectedUnregisteredContacts removeObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select.png"] forState:UIControlStateNormal];
        } else {
            [_selectedUnregisteredContacts addObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-active.png"] forState:UIControlStateNormal];
        }
    }
    
    [self updateFooterText];
}

- (void)updateFooterText {
    if ([_selectedRegisteredContacts count] > 0) {
        if ([_selectedUnregisteredContacts count] > 0) {
            [_footerLabel setText:@"Add and Invite"];
        } else if([_selectedRegisteredContacts count] > 1) {
            [_footerLabel setText:@"Add Friends"];
        } else {
            [_footerLabel setText:@"Add Friend"];
        }
    } else if([_selectedUnregisteredContacts count] > 0) {
        [_footerLabel setText:@"Invite"];
    } else {
        [_footerLabel setText:@"Select Some Contacts"];
    }
}

- (FriendMO *)friendForIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? [_registeredContacts objectAtIndex:indexPath.row] : [_unregisteredContacts objectAtIndex:indexPath.row];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    for (NSString *username in _smsContacts) {
        [FriendsDBManager updateUserSetStatusInvited:username];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    [self showEmail:_emailContacts];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    for (NSString *email in _emailContacts) {
        FriendMO *friend = [FriendsDBManager getUserWithEmail:email];
        [friend setValue:[NSNumber numberWithInt:STATUS_INVITED] forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
        [delegate saveContext];
    }
    _smsContacts = nil;
    _emailContacts = nil;
    
    [self refreshData];
}

- (void)showEmail:(NSArray *)recipients {
    
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your device doesn't support email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    // Email Subject
    NSString *emailTitle = @"Versapp Invitation";
    // Email Content
    NSString *messageBody = @"Check out this cool anonymous messaging app. It's called Versapp."; // Change the message body to HTML
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:recipients];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)showSMS:(NSArray *)recipients {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Check out this cool anonymous messaging app. It's called Versapp."];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    [footer setBackgroundColor:[UIColor clearColor]];
    return footer;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (IBAction)addNewContact:(id)sender {
    UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"User Search" message:@"Enter a phone number, or email address.  If we can find this user, we will send them a friend request." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    [groupNamePrompt setDelegate:self];
    [groupNamePrompt show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *searchValue = [alertView textFieldAtIndex:0].text;
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createUserSearchPacketWithSearchParam:searchValue]];
    }
}

- (IBAction)sendInvitations:(id)sender {
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    for (FriendMO *friend in _selectedRegisteredContacts) {
        [conn sendElement:[IQPacketManager createSubscribePacket:friend.username]];
        [FriendsDBManager updateUserSetStatusRequested:friend.username];
    }
    
    self.smsContacts = [[NSMutableArray alloc] initWithCapacity:[_selectedUnregisteredContacts count]];
    self.emailContacts = [[NSMutableArray alloc] initWithCapacity:[_selectedUnregisteredContacts count]];
    
    for (FriendMO *friend in _selectedUnregisteredContacts) {
        if (friend.username != nil) {
            [_smsContacts addObject:friend.username];
        } else if(friend.email != nil) {
            [_emailContacts addObject:friend.email];
        }
    }
    
    [self showSMS:_smsContacts];
}

@end
