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
#import "UIScrollView+GifPullToRefresh.h"

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
    
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    [self.footerLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, self.header.frame.size.height - 2.0f, self.view.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.header.layer addSublayer:headerBottomborder];
    
    // Add a topBorder to the footer view
    CALayer *footerTopBorder = [CALayer layer];
    footerTopBorder.frame = CGRectMake(0.0f, 0, self.view.frame.size.width, 2.0f);
    footerTopBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.footer.layer addSublayer:footerTopBorder];
    
    self.registeredContacts = [FriendsDBManager getAllWithStatusRegisteredOrRequested];
    self.unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    
    self.selectedRegisteredContacts = [[NSMutableArray alloc] initWithCapacity:[_registeredContacts count]];
    self.selectedUnregisteredContacts = [[NSMutableArray alloc] initWithCapacity:[_unregisteredContacts count]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UPDATE_CONTACTS_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:PACKET_ID_GET_VCARD object:nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"contacts-background-large.png"]];
    [self.tableView setBackgroundView:imageView];
    
    
    NSMutableArray *drawingImages = [NSMutableArray array];
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [drawingImages addObject:[UIImage imageNamed:fileName]];
    }
    
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [loadingImages addObject:[UIImage imageNamed:fileName]];
    }
    [_tableView addPullToRefreshWithDrawingImgs:drawingImages andLoadingImgs:loadingImages andActionHandler:^{
        //Do your own work when refreshing, and don't forget to end the animation after work finished.
        [self performSelectorOnMainThread:@selector(searchForContacts) withObject:nil waitUntilDone:NO];
    }];
}

-(void)searchForContacts {
    ContactSearchManager *csm = [ContactSearchManager getInstance];
    [csm accessContacts];
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
    [self.tableView didFinishPullToRefresh];
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
    NSLog(@"Friend: %@", [friend description]);
    if ([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_REGISTERED]]) {
        if ([_selectedRegisteredContacts containsObject:friend]) {
            [_selectedRegisteredContacts removeObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-green.png"] forState:UIControlStateNormal];
        } else {
            [_selectedRegisteredContacts addObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-green-active.png"] forState:UIControlStateNormal];
        }
    } else if([friend.status isEqualToNumber:[NSNumber numberWithInt:STATUS_UNREGISTERED]]) {
        if ([_selectedUnregisteredContacts containsObject:friend]) {
            [_selectedUnregisteredContacts removeObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-green.png"] forState:UIControlStateNormal];
        } else {
            [_selectedUnregisteredContacts addObject:friend];
            [[cell actionBtn] setImage:[UIImage imageNamed:@"cell-select-green-active.png"] forState:UIControlStateNormal];
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
    _smsContacts = [NSMutableArray array];
    [self dismissViewControllerAnimated:YES completion:nil];
    if([_emailContacts count] > 0) {
        [self showEmail:_emailContacts];
    } else {
        [_tableView reloadData];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
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
    
    /*UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:YES];
    [imageView setImage:[UIImage imageNamed:@"contacts-background-large.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView]; */
    
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
    if (section == 0) {
        return nil;
    }
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    [footer setBackgroundColor:[UIColor clearColor]];
    return footer;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section;
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

    if ([_selectedUnregisteredContacts count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Send Friend Requests" message:nil delegate:self cancelButtonTitle:@"Sweet" otherButtonTitles: nil] show];
        _selectedRegisteredContacts = [NSMutableArray array];
        [_tableView reloadData];
    }
    
    for (FriendMO *friend in _selectedUnregisteredContacts) {
        if (friend.searchedPhoneNumber != nil) {
            [_smsContacts addObject:friend.searchedPhoneNumber];
        } else if(friend.email != nil) {
            [_emailContacts addObject:friend.email];
        }
    }
    
    if ([_smsContacts count] > 0) {
        [self showSMS:_smsContacts];
    } else if([_emailContacts count] > 0) {
        [self showEmail:_emailContacts];
    }
    _selectedRegisteredContacts = [NSMutableArray array];
    _selectedUnregisteredContacts = [NSMutableArray array];
}

@end
