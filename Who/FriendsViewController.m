//
//  FriendsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

// View Controllers
#import "FriendsViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"

// Connection Related
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "IQPacketManager.h"

// Chat Related
#import "GroupChat.h"
#import "OneToOneChat.h"

// Constants
#import "Constants.h"

// Objects
#import "UserProfile.h"
#import "ChatParticipantVCardBuffer.h"
#import "MUCCreationManager.h"
#import "LoadingDialogManager.h"


@interface FriendsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *accepted;
@property (strong, nonatomic) NSArray *pending;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (strong, nonatomic) GroupChat *createdGroupChat;
@property (strong, nonatomic) OneToOneChat *createdOneToOneChat;
@property (strong, nonatomic) LoadingDialogManager *ldm;
@property (strong, nonatomic) NSString *invitedUser;

@property BOOL isSelecting;
@property BOOL isCreatingGroup;

@end

@implementation FriendsViewController

-(void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetRosterPacketReceived:) name:PACKET_ID_GET_ROSTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCreatedMUC:) name:NOTIFICATION_CREATED_MUC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedInvitingUsersToMUC:) name:NOTIFICATION_FINISHED_INVITING_MUC_USERS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedCreatingOneToOneChat:) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
    self.isSelecting = NO;
    self.isCreatingGroup = NO;
    self.selectedIndexPaths = [[NSMutableArray alloc] initWithCapacity:10];
    self.cp = [ConnectionProvider getInstance];
    self.ldm = [LoadingDialogManager create:self.view];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetRosterPacket]];
}

- (IBAction)beginSelectingFriendsForGroup:(id)sender {
    if(self.navigationItem.leftBarButtonItem != nil) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
        self.isSelecting = NO;
        if (self.selectedIndexPaths.count > 0) {
            self.isCreatingGroup = YES;
            UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Group Name" message:@"Enter a name for the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
            [groupNamePrompt show];
        }
    } else {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelSelectingFriendsForGroup:)] animated:YES];
        self.isSelecting = YES;
    }
}

- (IBAction)cancelSelectingFriendsForGroup:(id)sender {
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.isSelecting = NO;
    for (int i = 0; i < self.selectedIndexPaths.count; i++) {
        [[self.tableView cellForRowAtIndexPath:[self.selectedIndexPaths objectAtIndex:i]] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self.selectedIndexPaths removeAllObjects];
}

-(void)handleGetRosterPacketReceived: (NSNotification*) notification{
    NSLog(@"Received Notification");
    NSDictionary *data = notification.userInfo;
    NSMutableArray *pending = [data objectForKey:USER_STATUS_PENDING];
    NSMutableArray *accepted =[data objectForKey:USER_STATUS_FRIENDS];
    self.accepted = accepted;
    self.pending = pending;
    NSLog(@"I got handleGet");
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    }
    
    UserProfile *currentItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentItem = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        currentItem = [self.accepted objectAtIndex:indexPath.row];
    }
    
    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    if ([buff hasVCard:currentItem.jid] == YES) {
        currentItem.name = [buff getName:currentItem.jid];
        cell.textLabel.text = currentItem.name;
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text compare:@"Loading..."] != 0) {
        if (self.isSelecting) {
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                [self.selectedIndexPaths removeObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                [self.selectedIndexPaths addObject:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        } else {
            if ([self.searchResults count] > 0) {
                self.invitedUser = ((UserProfile*)[self.searchResults objectAtIndex:indexPath.row]).jid;
            } else {
                self.invitedUser = ((UserProfile*)[self.accepted objectAtIndex:indexPath.row]).jid;
            }
            UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Would you like to start an anonymous chat with %@", cell.textLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            groupNamePrompt.alertViewStyle = UIAlertViewStyleDefault;
            [groupNamePrompt show];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.accepted count];
    }
}

-(void)reloadData:(NSNotification*)notification {
    NSLog(@"Reloading Data...");
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResults = [self.accepted filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.isCreatingGroup == YES) {
        UITableViewCell *cell;
        NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithCapacity:self.selectedIndexPaths.count];
        NSString *groupName = [alertView textFieldAtIndex:0].text;
        for (int i = 0; i < self.selectedIndexPaths.count; i++) {
            NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ([self.searchResults count] > 0) {
                [selectedItems addObject:((UserProfile *)[self.searchResults objectAtIndex:indexPath.row]).jid];
            } else {
                [selectedItems addObject:((UserProfile *)[self.accepted objectAtIndex:indexPath.row]).jid];
            }
        }
        if (buttonIndex == 1 && groupName.length > 0) {
            [self.ldm showLoadingDialogWithoutProgress];
            self.createdGroupChat = [MUCCreationManager createMUC:groupName participants:selectedItems];
        }
        self.isCreatingGroup = NO;
    } else if (buttonIndex == 1) {
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        NSString *chatID = [Chat createGroupID];
        [conn sendElement:[IQPacketManager createCreateOneToOneChatPacket:chatID roomName:chatID]];
        self.createdOneToOneChat = [OneToOneChat create:chatID inviterID:[ConnectionProvider getUser] invitedID:self.invitedUser createdTimestamp:0];
    }
}

-(void)handleFinishedInvitingUsersToMUC:(NSNotification*)notification {
    [self.ldm hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_MUC sender:self];
}

-(void)handleFinishedCreatingOneToOneChat:(NSNotification*)notification {
    [self.ldm hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_CHAT sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier compare:SEGUE_ID_CREATED_MUC] == 0) {
        ConversationViewController *dest = segue.destinationViewController;
        dest.gc = self.createdGroupChat;
    } else if([segue.identifier compare:SEGUE_ID_CREATED_CHAT] == 0) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        dest.chat = self.createdOneToOneChat;
    }
}

@end
