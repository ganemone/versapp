//
//  ContactsViewController.m
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

@interface ContactsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *registeredContacts;
@property (strong, nonatomic) NSArray *unregisteredContacts;

@end

@implementation ContactsViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, self.header.frame.size.height - 2.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.header.layer addSublayer:headerBottomborder];
    
    self.registeredContacts = [FriendsDBManager getAllWithStatusRegistered];
    self.unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    
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
    _registeredContacts = [FriendsDBManager getAllWithStatusRegistered];
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

- (void)handleActionBtnClicked:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    FriendMO *friend = [self friendForIndexPath:indexPath];
    
    if ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_REGISTERED]]) {
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSubscribePacket:friend.username]];
    } else {
        if (friend.username != nil) {
            [self showSMS:@[friend.username]];
        } else {
            // Prompt for email...
        }
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
@end
