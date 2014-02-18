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
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) ChatParticipantVCardBuffer *buff;
@property (strong, nonatomic) NSArray *allAccepted;
@property (strong, nonatomic) NSMutableArray *selectedJIDs;
@property (strong, nonatomic) GroupChat *createdGroupChat;
@property (strong, nonatomic) OneToOneChat *createdOneToOneChat;
@property (strong, nonatomic) LoadingDialogManager *ldm;
@property (strong, nonatomic) NSString *invitedUser;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property BOOL isSelecting;
@property BOOL isCreatingGroup;
@property BOOL isSearching;

@end

@implementation FriendsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"View did load");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedInvitingUsersToMUC:) name:NOTIFICATION_FINISHED_INVITING_MUC_USERS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCreatedOneToOneChat:) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self.searchBar setSearchBarStyle:UISearchBarStyleProminent];
    [self.searchBar setDelegate:self];
    
    self.isSelecting = NO;
    self.isCreatingGroup = NO;
    self.selectedJIDs = [[NSMutableArray alloc] initWithCapacity:10];
    self.cp = [ConnectionProvider getInstance];
    self.ldm = [LoadingDialogManager create:self.view];
    self.buff = [ChatParticipantVCardBuffer getInstance];
    self.allAccepted = [self.buff getAcceptedUserProfiles];
    self.searchResults = _allAccepted;
}

- (IBAction)beginSelectingFriendsForGroup:(id)sender {
    if(self.isSelecting) {
        [self.cancelButton setHidden:YES];
        self.isSelecting = NO;
        if (self.selectedJIDs.count > 0) {
            self.isCreatingGroup = YES;
            UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Group Name" message:@"Enter a name for the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
            [groupNamePrompt show];
        }
    } else {
        [self.createButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.cancelButton setHidden:NO];
        self.isSelecting = YES;
    }
}

- (IBAction)cancelSelectingFriendsForGroup:(id)sender {
    [self.createButton setTitle:@"Create" forState:UIControlStateNormal];
    [self.cancelButton setHidden:YES];
    self.isSelecting = NO;
    for (int i = 0; i < self.buff.accepted.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [[self.tableView cellForRowAtIndexPath:path] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self.selectedJIDs removeAllObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    }
    
    UserProfile *currentItem = [self.searchResults objectAtIndex:indexPath.row];
    
    if ([_buff hasVCard:currentItem.jid] == YES) {
        currentItem.nickname = [_buff getName:currentItem.jid];
        cell.textLabel.text = currentItem.nickname;
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    if ([self.selectedJIDs containsObject:currentItem.jid]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text compare:@"Loading..."] != 0) {
        NSString *jid;
        if ([self.searchResults count] > 0) {
            jid = ((UserProfile*)[self.searchResults objectAtIndex:indexPath.row]).jid;
        } else {
            jid = ((UserProfile*)[self.buff getVCard:[self.buff.accepted objectAtIndex:indexPath.row]]).jid;
        }
        if (self.isSelecting) {
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
                [self.selectedJIDs removeObject:jid];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                [self.selectedJIDs addObject:jid];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        } else {
            self.invitedUser = jid;
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
    return self.searchResults.count;
}

-(void)reloadData:(NSNotification*)notification {
    [self.tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.isCreatingGroup == YES) {
        NSString *groupName = [alertView textFieldAtIndex:0].text;
        if (buttonIndex == 1 && groupName.length > 0) {
            [self.ldm showLoadingDialogWithoutProgress];
            self.createdGroupChat = [MUCCreationManager createMUC:groupName participants:self.selectedJIDs];
        }
        self.isCreatingGroup = NO;
    } else if (buttonIndex == 1) {
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        NSString *chatID = [Chat createGroupID];
        [conn sendElement:[IQPacketManager createCreateOneToOneChatPacket:chatID roomName:chatID]];
        self.createdOneToOneChat = [OneToOneChat create:chatID inviterID:[ConnectionProvider getUser] invitedID:self.invitedUser createdTimestamp:0];
    }
    self.selectedJIDs = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

-(void)handleFinishedInvitingUsersToMUC:(NSNotification*)notification {
    [self.ldm hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_MUC sender:self];
}

-(void)handleCreatedOneToOneChat:(NSNotification*)notification {
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:self.createdOneToOneChat.chatID invitedUsername:self.createdOneToOneChat.inviterID]];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:self.createdOneToOneChat.chatID invitedUsername:self.createdOneToOneChat.invitedID]];
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.isSearching = YES;
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"nickname contains[c] %@", searchText];
        self.searchResults = [_allAccepted filteredArrayUsingPredicate:resultPredicate];
    } else {
        self.isSearching = NO;
        self.searchResults = _allAccepted;
    }
    [self.tableView reloadData];
}


@end
