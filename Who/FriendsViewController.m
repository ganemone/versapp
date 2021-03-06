//
//  FriendsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

//App Delegate
#import "AppDelegate.h"

// View Controllers
#import "FriendsViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"

// Connection Related
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

// Constants
#import "Constants.h"

// Objects
#import "MUCCreationManager.h"
#import "FriendTableViewCell.h"
// DB
#import "FriendsDBManager.h"
#import "ChatDBManager.h"
#import "StyleManager.h"

#import "UserDefaultManager.h"
#import "MBProgressHUD.h"

#import "WSCoachMarksView.h"


@interface FriendsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *allAccepted;
@property (strong, nonatomic) NSMutableArray *selectedJIDs;
@property (strong, nonatomic) ChatMO *createdChat;
@property (strong, nonatomic) NSString *invitedUser;
@property (strong, nonatomic) CustomIOS7AlertView *groupNamePrompt;
@property (strong, nonatomic) CustomIOS7AlertView *unfriendAlertView;
@property (strong, nonatomic) FriendMO *unfriendCheck;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *noFriendsView;
@property (weak, nonatomic) IBOutlet UIView *noFriendsBlackView;
@property (weak, nonatomic) IBOutlet UIButton *findFriendsBtn;
@property (weak, nonatomic) IBOutlet UILabel *noFriendsLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *startConversationBtn;

@property BOOL isCreatingGroup;

@end

@implementation FriendsViewController

- (void)viewDidAppear:(BOOL)animated {
    if (![UserDefaultManager hasSeenFriends] && [_allAccepted count] > 0) {
        [UserDefaultManager setSeenFriendsTrue];
        //[[[UIAlertView alloc] initWithTitle:@"Friends" message:@"This is your friends page. Your friends are chosen based on your phone contacts. Start conversations by selecting one or more friends on this page." delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil] show];
        [self doTutorial];
    }
    if ([_allAccepted count] > 0)
    {
        [self.view sendSubviewToBack:self.noFriendsBlackView];
        [self.view sendSubviewToBack:self.noFriendsView];
        [self.noFriendsView setHidden:YES];
        [self.noFriendsView setUserInteractionEnabled:NO];
        [self.noFriendsBlackView setHidden:YES];
        [self.noFriendsBlackView setUserInteractionEnabled:NO];
    }
    else
    {
        [self.view bringSubviewToFront:self.noFriendsBlackView];
        [self.view bringSubviewToFront:self.noFriendsView];
        [self.noFriendsView setHidden:NO];
        [self.noFriendsView setUserInteractionEnabled:YES];
        [self.noFriendsBlackView setHidden:NO];
        [self.noFriendsBlackView setUserInteractionEnabled:YES];
        [self.view bringSubviewToFront:self.noFriendsView];
    }
    [self updateFooterView];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:PACKET_ID_GET_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTIFICATION_UPDATE_FRIENDS object:nil];
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
    self.allAccepted = [FriendsDBManager getAllWithStatusFriends];
    self.searchResults = _allAccepted;
    
    [self.header setFont:[StyleManager getFontStyleLightSizeHeader]];
    [self.bottomLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"friends-background-large.png"]];
    
    [self.tableView setBackgroundView:imageView];
    
    
    [self.findFriendsBtn.layer setCornerRadius:5.0];
    [self.findFriendsBtn.layer setBorderWidth:0.0];
    
    [self.noFriendsBlackView setFrame:CGRectMake(0, self.headerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.headerView.frame.size.height)];
    [self.noFriendsView setFrame:self.noFriendsBlackView.frame];
    [self.noFriendsLabel setFont:[StyleManager getFontStyleMediumSizeLarge]];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createButtonClicked:)];
    [_footerView addGestureRecognizer:gr];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [_tableView addGestureRecognizer:lpgr];
    
    [[self startConversationBtn] setHidden:YES];
    
    for (UIView *subview in self.searchBar.subviews)
    {
        for (UIView *subSubview in subview.subviews)
        {
            if ([subSubview conformsToProtocol:@protocol(UITextInputTraits)])
            {
                UITextField *textField = (UITextField *)subSubview;
                [textField setKeyboardAppearance: UIKeyboardAppearanceDark];
                [textField setReturnKeyType:UIReturnKeyGo];
                [textField setDelegate:self];
                break;
            }
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)handleNoFriendsBtnClicked:(id)sender
{
    NSDictionary *userInfo = @{@"direction" : @(UIPageViewControllerNavigationDirectionForward)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_CONTACTS
                                                        object:nil
                                                      userInfo:userInfo];
}

-(void)doTutorial {
    NSMutableArray *coachMarks = [[NSMutableArray alloc] initWithArray:@[
                                                                         @{
                                                                             @"rect": [NSValue valueWithCGRect:(CGRect){{_headerView.frame.origin.x,_headerView.frame.origin.y},{_headerView.frame.size.width, _headerView.frame.size.height}}],//(CGRect){{0,0},{self.view.frame.size.width,44}}],
                                                                             @"caption": @"This page shows your friends in Versapp."
                                                                             },
                                                                         @{
                                                                             @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width - 50, 20},{40,40}}],
                                                                             @"caption": @"Click here to add a friend based on their username."
                                                                             },
                                                                         ]];
    
    if ([_allAccepted count] > 0) {
        [coachMarks addObject:@{@"rect":[NSValue valueWithCGRect:(CGRect){{0,_headerView.frame.size.height + _searchBar.frame.size.height},{self.view.frame.size.width, 44}}],
                                @"caption":@"Select a friend to start a conversation anonymously. You will know their identity, but they won't know yours!"
                                }];
        if ([_allAccepted count] > 1) {
            [coachMarks addObject:@{@"rect":[NSValue valueWithCGRect:(CGRect){{0, _headerView.frame.size.height + _searchBar.frame.size.height},{self.view.frame.size.width, 88}}],
                                    @"caption":@"Select multiple friends to start a group conversation. All the participants are known, but individual messages remain anonymous."
                                    }];
        }
        [coachMarks addObject:@{@"rect": [NSValue valueWithCGRect:(CGRect){{0, self.view.frame.size.height - 40},{self.view.frame.size.width, 40}}],
                                @"caption":@"Use this bar to initiate the conversation"}];
    }
    
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    [self.view addSubview:coachMarksView];
    [coachMarksView start];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendMO *currentItem = (self.searchResults)[(NSUInteger) indexPath.row];
    FriendTableViewCell *cell = [[FriendTableViewCell alloc] initWithFriend:currentItem reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    if (currentItem.name == nil) {
        NSLog(@"Current Item: %@ %@", currentItem.username, currentItem.name);
        [[_cp getConnection] sendElement:[IQPacketManager createGetVCardPacket:currentItem.username]];
    }
    
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
            jid = [self.searchResults[(NSUInteger) indexPath.row] username];
        } else {
            jid = [[self allAccepted][(NSUInteger) indexPath.row] username];
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
    [self updateFooterView];
}

-(void)updateFooterView {
    [UIView animateWithDuration:0.25 animations:^{
        if ([_selectedJIDs count] == 0) {
            [_bottomView setBackgroundColor:[UIColor whiteColor]];
            [_bottomLabel setTextColor:[StyleManager getColorPurple]];
            [_bottomLabel setText:@"Select Some Friends"];
            [_startConversationBtn setHidden:YES];
        } else if([_selectedJIDs count] == 1) {
            [_bottomView setBackgroundColor:[StyleManager getColorPurple]];
            [_bottomLabel setTextColor:[UIColor whiteColor]];
            [_bottomLabel setText:@"Start One to One Conversation"];
            [_startConversationBtn setHidden:NO];
        } else {
            [_bottomView setBackgroundColor:[StyleManager getColorPurple]];
            [_bottomLabel setTextColor:[UIColor whiteColor]];
            [_bottomLabel setText:@"Start Group Conversation"];
            [_startConversationBtn setHidden:NO];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

-(void)reloadData {
    _allAccepted = [FriendsDBManager getAllWithStatusFriends];
    _searchResults = _allAccepted;
    [self.tableView reloadData];
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"] || [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Ok"]) {
        [alertView close];
    } else if (alertView == _groupNamePrompt) {
        if (self.isCreatingGroup) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *groupName = [alertView getInputText];
            if (buttonIndex == 1 && groupName.length > 0) {
                ChatMO *gc = [MUCCreationManager createMUC:groupName participants:self.selectedJIDs];
                _createdChat = [ChatDBManager insertChatWithID:gc.chat_id chatName:groupName chatType:CHAT_TYPE_GROUP participantString:[self.selectedJIDs componentsJoinedByString:@", "] status:STATUS_JOINED degree:@"1"];
                [alertView endEditing:YES];
                [alertView close];
                [self handleFinishedInvitingUsersToMUC];
            }
            self.isCreatingGroup = NO;
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
            NSString *chatID = [ChatMO createGroupID];
            [conn sendElement:[IQPacketManager createCreateOneToOneChatPacket:chatID invitedUser:self.invitedUser roomName:@"Anonymous Friend"]];
            NSString *chatName = [FriendsDBManager getUserWithUsername:self.invitedUser].name;
            _createdChat = [ChatDBManager insertChatWithID:chatID chatName:chatName chatType:CHAT_TYPE_ONE_TO_ONE_INVITER participantString:[NSString stringWithFormat:@"%@, %@", [ConnectionProvider getUser], self.invitedUser] status:STATUS_JOINED degree:@"1"];
            [alertView close];
        }
        self.selectedJIDs = [[NSMutableArray alloc] init];
        [self.bottomLabel setText:@"Select Some Friends"];
        [self.tableView reloadData];
    } else if (alertView == _unfriendAlertView) {
        [alertView close];
        [self handleUnfriend:_unfriendCheck];
    }
}

-(void)handleFinishedInvitingUsersToMUC {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_MUC sender:self];
}

-(void)handleCreatedOneToOneChat:(NSNotification*)notification {
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:_createdChat.chat_id invitedUsername:self.invitedUser]];
    [conn sendElement:[IQPacketManager createInviteToChatPacket:_createdChat.chat_id invitedUsername:[ConnectionProvider getUser]]];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_CHAT sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_ID_CREATED_MUC]) {
        ConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    } else if([segue.identifier isEqualToString:SEGUE_ID_CREATED_CHAT]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        self.searchResults = [_allAccepted filteredArrayUsingPredicate:resultPredicate];
    } else {
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

/*- (IBAction)confessionsIconClicked:(id)sender {
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
 }*/

- (IBAction)createButtonClicked:(id)sender {
    if ([_selectedJIDs count] == 0) {
        //_groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You must select some friends first!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        _groupNamePrompt = [StyleManager createCustomAlertView:@"Whoops!" message:@"You must select some friends first!" buttons:[@[@"Ok"] mutableCopy] hasInput:NO];
        [_groupNamePrompt setDelegate:self];
        [_groupNamePrompt show];
    } else if ([_selectedJIDs count] == 1) {
        [self confirmCreateOneToOneChat:[FriendsDBManager getUserWithUsername:[_selectedJIDs firstObject]]];
    } else {
        self.isCreatingGroup = YES;
        [self promptForGroupName];
    }
}

- (void)promptForGroupName {
    //_groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Group Name" message:@"Enter a name for the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    //_groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    _groupNamePrompt = [StyleManager createCustomAlertView:@"Group Name" message:@"Enter a name for the group" buttons:[@[@"Cancel", @"Create"] mutableCopy] hasInput:YES];
    [_groupNamePrompt setDelegate:self];
    [_groupNamePrompt show];
}

- (void)confirmCreateOneToOneChat:(FriendMO*)friend {
    self.invitedUser = friend.username;
    //_groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Would you like to start an anonymous chat with %@?", friend.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
    //_groupNamePrompt.alertViewStyle = UIAlertViewStyleDefault;
    
    _groupNamePrompt = [StyleManager createCustomAlertView:@"Confirmation" message:[NSString stringWithFormat:@"Start an anonymous chat with %@?", friend.name] buttons:[@[@"Cancel", @"Create"] mutableCopy] hasInput:NO];
    [_groupNamePrompt setDelegate:self];
    [_groupNamePrompt show];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath == nil) {
        }
        else {
            [self handleLongPressForRowAtIndexPath:indexPath];
        }
    }
}

-(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
    _unfriendCheck = _searchResults[(NSUInteger) indexPath.row];
    NSLog(@"Unfriend User?: %@", [_unfriendCheck username]);
    
    _unfriendAlertView = [StyleManager createCustomAlertView:@"Remove Friend" message:[NSString stringWithFormat:@"Remove %@ from your friends list?", _unfriendCheck.name] buttons:[@[@"Cancel", @"Remove"] mutableCopy] hasInput:NO];
    [_unfriendAlertView setDelegate:self];
    [_unfriendAlertView show];
}

-(void)handleUnfriend:(FriendMO*)friend {
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    [conn sendElement:[IQPacketManager createRemoveFriendPacket:friend.username]];
    [FriendsDBManager deleteUser:friend];
    [self reloadData];
    _unfriendCheck = nil;
}

@end
