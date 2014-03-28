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

// Constants
#import "Constants.h"

// Objects
#import "MUCCreationManager.h"
#import "LoadingDialogManager.h"
#import "FriendTableViewCell.h"
// DB
#import "FriendMO.h"
#import "FriendsDBManager.h"
#import "ChatMO.h"
#import "ChatDBManager.h"
#import "StyleManager.h"

@interface FriendsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *allAccepted;
@property (strong, nonatomic) NSMutableArray *selectedJIDs;
@property (strong, nonatomic) ChatMO *createdChat;
@property (strong, nonatomic) LoadingDialogManager *ldm;
@property (strong, nonatomic) NSString *invitedUser;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property BOOL isCreatingGroup;
@property BOOL isSearching;

@end

@implementation FriendsViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"View did load");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedInvitingUsersToMUC:) name:NOTIFICATION_FINISHED_INVITING_MUC_USERS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCreatedOneToOneChat:) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[StyleManager getColorPurple]];
    [self.tableView setBackgroundColor:[StyleManager getColorPurple]];
    
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [self.searchBar setDelegate:self];
    
    self.isCreatingGroup = NO;
    self.selectedJIDs = [[NSMutableArray alloc] initWithCapacity:10];
    self.cp = [ConnectionProvider getInstance];
    self.ldm = [LoadingDialogManager create:self.view];
    self.allAccepted = [FriendsDBManager getAllWithStatusFriends];
    self.searchResults = _allAccepted;
    
    [self.header setFont:[StyleManager getFontStyleLightSizeXL]];
    [self.bottomLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
}

/*- (IBAction)beginSelectingFriendsForGroup:(id)sender {
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
    for (int i = 0; i < self.allAccepted.count; i++) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [[self.tableView cellForRowAtIndexPath:path] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self.selectedJIDs removeAllObjects];
}*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendMO *currentItem = [self.searchResults objectAtIndex:indexPath.row];
    FriendTableViewCell *cell = [[FriendTableViewCell alloc] initWithText:currentItem.name reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    if ([self.selectedJIDs containsObject:currentItem.username]) {
        [cell.isSelectedImageView setImage:[UIImage imageNamed:@"cell-select-active.png"]];
    } else {
        [cell.isSelectedImageView setImage:[UIImage imageNamed:@"cell-select.png"]];
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    [footer setBackgroundColor:[UIColor clearColor]];
    return footer;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text compare:@"Loading..."] != 0) {
        NSString *jid;
        if ([self.searchResults count] > 0) {
            jid = [[self.searchResults objectAtIndex:indexPath.row] username];
        } else {
            jid = [[[self allAccepted] objectAtIndex:indexPath.row] username];
        }
        if([self.selectedJIDs containsObject:jid]) {
            [self.selectedJIDs removeObject:jid];
            [cell setCellUnselected];
        } else {
            [self.selectedJIDs addObject:jid];
            [cell setCellSelected];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([_selectedJIDs count] == 0) {
        [_bottomLabel setText:@"Select Some Friends"];
    } else if([_selectedJIDs count] == 1) {
        [_bottomLabel setText:@"Start One to One Conversation"];
    } else {
        [_bottomLabel setText:@"Start Group Conversation"];
    }
    
    NSLog(@"Selected: %@", _selectedJIDs);
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
            ChatMO *gc = [MUCCreationManager createMUC:groupName participants:self.selectedJIDs];
            _createdChat = [ChatDBManager insertChatWithID:gc.chat_id chatName:groupName chatType:CHAT_TYPE_GROUP participantString:[self.selectedJIDs componentsJoinedByString:@", "] status:STATUS_JOINED];
            [self handleFinishedInvitingUsersToMUC];
        }
        self.isCreatingGroup = NO;
    } else if (buttonIndex == 1) {
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        NSString *chatID = [ChatMO createGroupID];
        [conn sendElement:[IQPacketManager createCreateOneToOneChatPacket:chatID invitedUser:self.invitedUser roomName:@"Anonymous Friend"]];
        _createdChat = [ChatDBManager insertChatWithID:chatID chatName:[FriendsDBManager getUserWithJID:self.invitedUser].name chatType:CHAT_TYPE_ONE_TO_ONE participantString:[NSString stringWithFormat:@"%@, %@", [ConnectionProvider getUser], self.invitedUser] status:STATUS_JOINED];
    }
    self.selectedJIDs = [[NSMutableArray alloc] init];
    [self.bottomLabel setText:@"Select Some Friends"];
    [self.tableView reloadData];
}

-(void)handleFinishedInvitingUsersToMUC {
    [self.ldm hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_MUC sender:self];
}

-(void)handleCreatedOneToOneChat:(NSNotification*)notification {
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:_createdChat.chat_id invitedUsername:self.invitedUser]];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:_createdChat.chat_id invitedUsername:[ConnectionProvider getUser]]];
    [self.ldm hideLoadingDialogWithoutProgress];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_CHAT sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier compare:SEGUE_ID_CREATED_MUC] == 0) {
        ConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    } else if([segue.identifier compare:SEGUE_ID_CREATED_CHAT] == 0) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.isSearching = YES;
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        self.searchResults = [_allAccepted filteredArrayUsingPredicate:resultPredicate];
    } else {
        self.isSearching = NO;
        self.searchResults = _allAccepted;
    }
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = _allAccepted;
    [self.tableView reloadData];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (IBAction)confessionsIconClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionReverse], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_CONFESSIONS
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)addIconClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionForward], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_CONTACTS
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)createButtonClicked:(id)sender {
    if ([_selectedJIDs count] == 0) {
        UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You must select some friends first!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [groupNamePrompt show];
    } else if ([_selectedJIDs count] == 1) {
        [self confirmCreateOneToOneChat:[FriendsDBManager getUserWithJID:[_selectedJIDs firstObject]]];
    } else {
        self.isCreatingGroup = YES;
        [self promptForGroupName];
    }
}

- (void)promptForGroupName {
    UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Group Name" message:@"Enter a name for the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    [groupNamePrompt show];
}

- (void)confirmCreateOneToOneChat:(FriendMO*)friend {
    self.invitedUser = friend.username;
    UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Would you like to start an anonymous chat with %@", friend.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    groupNamePrompt.alertViewStyle = UIAlertViewStyleDefault;
    [groupNamePrompt show];
}

@end
