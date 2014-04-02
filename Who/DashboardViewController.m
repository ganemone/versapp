//
//  DashboardViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "MessagesDBManager.h"
#import "ChatDBManager.h"
#import "ChatMO.h"
#import "StyleManager.h"
#import "FriendsDBManager.h"
#import "SWTableViewCell.h"
#import "MainSwipeViewController.h"
#import "AppDelegate.h"

@interface DashboardViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSString *timeLastActive;
@property (strong, nonatomic) NSIndexPath *clickedCellIndexPath;
@property (strong, nonatomic) NSArray *groupChats;
@property (strong, nonatomic) NSArray *oneToOneChats;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *footerView;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIButton *notificationsButton;
@property (strong, nonatomic) IBOutlet UIButton *notificationsButtonGreen;
@property (strong, nonatomic) UIView *notificationsHeader;
@property (strong, nonatomic) UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *friendRequests;
@property (strong, nonatomic) NSMutableArray *groupInvites;
@property (strong, nonatomic) ChatMO *editingChat;

@end

@implementation DashboardViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetLastPacketReceived:) name:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:PACKET_ID_GET_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications) name:NOTIFICATION_UPDATE_NOTIFICATIONS object:nil];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.cp = [ConnectionProvider getInstance];
    
    [self.header setFont:[StyleManager getFontStyleMediumSizeXL]];
    [self.header setTextColor:[UIColor whiteColor]];
    [self.footerView setFont:[StyleManager getFontStyleLightSizeXL]];
    
    
    self.groupChats = [ChatDBManager getAllActiveGroupChats];
    self.oneToOneChats = [ChatDBManager getAllActiveOneToOneChats];
    [self loadNotifications];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [_tableView addGestureRecognizer:lpgr];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"messages-background-large.png"]];
    [self.tableView setBackgroundView:imageView];
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"View will appear");
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)arrowClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionForward], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_FRIENDS
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)settingsClicked:(id)sender {
    [self performSegueWithIdentifier:SEGUE_ID_SETTINGS sender:self];
}

- (IBAction)notificationsClicked:(id)sender {
    [self showNotifications];
}

- (IBAction)notificationsGreenClicked:(id)sender {
    [self hideNotifications];
}

- (IBAction)toggleEditing:(id)sender {
    UIButton *button = (UIButton*)sender;
    if ([_tableView isEditing]) {
        [button setTitle:@"" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"edit-icon.png"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLE_DASHBOARD_EDITING object:nil];
        [_tableView setEditing:NO animated:YES];
    } else {
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_DASHBOARD_EDITING object:nil];
        [_tableView setEditing:YES animated:YES];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier compare:SEGUE_ID_GROUP_CONVERSATION] == 0) {
        ConversationViewController *dest = segue.destinationViewController;
        dest.chatMO = [[self groupChats] objectAtIndex:self.clickedCellIndexPath.row];
    } else if([segue.identifier compare:SEGUE_ID_ONE_TO_ONE_CONVERSATION] == 0) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        dest.chatMO = [self.oneToOneChats objectAtIndex:self.clickedCellIndexPath.row];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return 2;
    } else {
        return 2;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return (section == 0) ? @"Groups" : @"One to One";
    } else {
        if (section == 0) {
            if (self.groupInvites.count == 0)
                return nil;
            else
                return NOTIFICATIONS_GROUP;
        }
        else {
            if (self.friendRequests.count == 0)
                return nil;
            else
                return NOTIFICATIONS_FRIEND;
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        static NSString *CellIdentifier = @"ChatCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setHidden:NO];
        
        ChatMO *chatMo;
        if(indexPath.section == 0) {
            chatMo = [self.groupChats objectAtIndex:indexPath.row];
        } else {
            chatMo = [self.oneToOneChats objectAtIndex:indexPath.row];
        }
        
        //if ([chatMo.chat_type compare:CHAT_TYPE_ONE_TO_ONE] == 0 && [[ConnectionProvider getUser] compare:[chatMo.chat_id substringToIndex:[[ConnectionProvider getUser] length]]] != 0) {
        //  [cell.textLabel setText:ANONYMOUS_FRIEND];
        //} else {
        [cell.textLabel setText:[chatMo getChatName]];
        //}
        [cell.detailTextLabel setText:[chatMo getLastMessage]];
        
        if ([ChatDBManager doesChatHaveNewMessage:chatMo.chat_id]) {
            [cell.textLabel setFont:[StyleManager getFontStyleBoldSizeLarge]];
            [cell.detailTextLabel setFont:[StyleManager getFontStyleBoldSizeMed]];
        } else {
            [cell.textLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
            [cell.detailTextLabel setFont:[StyleManager getFontStyleLightSizeMed]];
        }
        
        [cell setBackgroundColor:[UIColor whiteColor]];
        return cell;
    } else {
        static NSString *cellIdentifier = @"Cell";
        
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier containingTableView:self.notificationTableView leftUtilityButtons:nil rightUtilityButtons:[self notificationsButtons]];
            cell.delegate = self;
        }
        
        NSLog(@"Cell: %@", [cell description]);
        
        if (indexPath.section == 0) {
            ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
            //cell.textLabel.text = groupInvite.chat_name;
            NSString *inviter = [FriendsDBManager getUserWithJID:groupInvite.owner_id].name;
            //cell.textLabel.text = [NSMutableString stringWithFormat:@"%@ - invited by %@", groupInvite.chat_name, inviter];
            cell.textLabel.text = groupInvite.chat_name;
            cell.detailTextLabel.text = [NSMutableString stringWithFormat:@"invited by %@", inviter];
        } else {
            FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
            cell.textLabel.text = friendRequest.name;
        }
        
        [cell.textLabel setFont:[StyleManager getFontStyleBoldSizeLarge]];
        [cell.textLabel setTextColor:[StyleManager getColorGreen]];
        [cell.detailTextLabel setFont:[StyleManager getFontStyleBoldSizeSmall]];
        [cell.detailTextLabel setTextColor:[StyleManager getColorGreen]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        self.clickedCellIndexPath = indexPath;
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section == 0) {
            [self performSegueWithIdentifier:SEGUE_ID_GROUP_CONVERSATION sender:self];
        } else {
            [self performSegueWithIdentifier:SEGUE_ID_ONE_TO_ONE_CONVERSATION sender:self];
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView && [_tableView isEditing]) {
        return YES;
    }
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        return YES;
    }
    return NO;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave Chat?";
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Finished Editing...");
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChatMO *chat = (indexPath.section == 0) ? [_groupChats objectAtIndex:indexPath.row] : [_oneToOneChats objectAtIndex:indexPath.row];
        [MessagesDBManager deleteMessagesFromChatWithID:chat.chat_id];
        [ChatDBManager deleteChat:chat];
        if (indexPath.section == 0) {
            _groupChats = [ChatDBManager getAllActiveGroupChats];
        } else {
            _oneToOneChats = [ChatDBManager getAllActiveOneToOneChats];
        }
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if(section == 0) {
            return [self.groupChats count];
        } else {
            return [self.oneToOneChats count];
        }
    } else {
        if (section == 0) {
            return [self.groupInvites count];
        } else {
            return [self.friendRequests count];
        }
    }
}

- (NSArray *)notificationsButtons {
    NSMutableArray *buttons = [NSMutableArray new];
    UIImage *accept = [UIImage imageNamed:@"check-icon-green.png"];
    UIImage *decline = [UIImage imageNamed:@"decline-icon-green.png"];
    [buttons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:accept];
    [buttons sw_addUtilityButtonWithColor:[UIColor clearColor] icon:decline];
    
    return buttons;
}

- (void) swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.notificationTableView indexPathForCell:cell];
    switch (index) {
        case 0:
            NSLog(@"accept pressed");
            if (indexPath.section == 0)
                [self acceptInvitation:indexPath];
            else
                [self acceptFriendRequest:indexPath];
            break;
        case 1:
            NSLog(@"decline pressed");
            if (indexPath.section == 0)
                [self declineInvitation:indexPath];
            else
                [self declineFriendRequest:indexPath];
            break;
        default:
            break;
    }
}

- (void) showNotifications {
    NSLog(@"Show Notifications");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLE_SWIPE object:nil];
    
    CGRect notificationFrame = self.notificationTableView.frame;
    notificationFrame.origin.y = 0;
    
    self.notificationTableView.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.notificationTableView.frame = notificationFrame;
                         self.tableView.backgroundColor = [UIColor grayColor];
                         self.tableView.alpha = 0.5;
                         self.footerView.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         [self.tableView setUserInteractionEnabled:NO];
                     }];
    [UIView commitAnimations];
}

- (void) hideNotifications {
    NSLog(@"Hide Notifications");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_SWIPE object:nil];
    
    self.groupChats = [ChatDBManager getAllActiveGroupChats];
    [self.tableView reloadData];
    
    CGRect notificationFrame = self.notificationTableView.frame;
    notificationFrame.origin.y = -1*self.notificationTableView.frame.size.height;
    
    [UIView animateWithDuration:0.5
                          delay:0.2
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.notificationTableView.frame = notificationFrame;
                         self.tableView.backgroundColor = [UIColor clearColor];
                         self.tableView.alpha = 1;
                         self.footerView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         self.notificationTableView.hidden = YES;
                         [self.tableView setUserInteractionEnabled:YES];
                     }];
    [UIView commitAnimations];
}

- (IBAction)tapToHideNotifications:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.view];
    
    if (!CGRectContainsPoint(self.notificationTableView.frame, tapLocation) && !self.notificationTableView.hidden) {
        [self hideNotifications];
    }
}

-(void)setNotificationsIcon {
    NSMutableString *imageName;
    NSMutableString *greenImageName;
    if ([self.friendRequests count] + [self.groupInvites count] > 0 && [self.friendRequests count] + [self.groupInvites count] < 6) {
        imageName = [NSMutableString stringWithFormat:@"notification%d.png", [self.friendRequests count] + [self.groupInvites count]];
        //greenImageName = [NSMutableString stringWithFormat:@"notification%d-green.png", [self.friendRequests count] + [self.groupInvites count]];
    } else if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        imageName = [NSMutableString stringWithString:@"notification-none.png"];
        //greenImageName = [NSMutableString stringWithString:@"arrow-up-icon-square-green.png"];
    } else {
        imageName = [NSMutableString stringWithString:@"notification5+.png"];
        //greenImageName = [NSMutableString stringWithString:@"notification5+-green.png"];
    }
    UIImage *notificationsImage = [UIImage imageNamed:imageName];
    UIImageView *notificationsBadgeGreen = [[UIImageView alloc] initWithFrame:CGRectMake(244, 29, 28, 28)];
    [self.notificationsButton setImage:notificationsImage forState:UIControlStateNormal];
    greenImageName = [NSMutableString stringWithString:@"arrow-up-icon-square-green.png"];
    UIImage *notificationsImageGreen = [UIImage imageNamed:greenImageName];
    [notificationsBadgeGreen setImage:notificationsImageGreen];
    self.notificationsButtonGreen = [[UIButton alloc] initWithFrame:CGRectMake(244, 29, 28, 28)];
    [self.notificationsButtonGreen setImage:notificationsImageGreen forState:UIControlStateNormal];
    [self.notificationsButtonGreen addTarget:self action:@selector(notificationsGreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        self.notificationsHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.5)];
        UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height*0.25, 280, 21)];
        [notificationsLabel setText:NO_NOTIFICATIONS];
        [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
        [notificationsLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
        [notificationsLabel setTextColor:[StyleManager getColorBlue]];
        [self.notificationsHeader addSubview:notificationsLabel];
        [self.notificationsHeader addSubview:self.notificationsButtonGreen];
        [self.notificationTableView setTableHeaderView:self.notificationsHeader];
    } else {
        self.notificationsHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
        UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 280, 21)];
        [notificationsLabel setText:NOTIFICATIONS];
        [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
        [notificationsLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
        [notificationsLabel setTextColor:[StyleManager getColorGreen]];
        [self.notificationsHeader addSubview:notificationsLabel];
        [self.notificationsHeader addSubview:self.notificationsButtonGreen];
    }
    [self.notificationTableView setTableHeaderView:self.notificationsHeader];
}

-(void)loadNotifications {
    NSLog(@"Load notifications");
    
    self.groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    self.friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    
    [self setNotificationsIcon];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideNotifications:)];
    tapRecognizer.delaysTouchesEnded = YES;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.5)];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
    
    [self.notificationTableView setTableHeaderView:self.notificationsHeader];
    [self.notificationTableView setSeparatorColor:[StyleManager getColorGreen]];
    
    [self.view addSubview:self.notificationTableView];
    [self hideNotifications];
}

- (void)updateNotifications {
    _groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    _friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    [self.notificationTableView reloadData];
    [self setNotificationsIcon];
}

- (void)acceptInvitation:(NSIndexPath *)indexPath {
    ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:groupInvite.chat_id]];
    [[self.cp getConnection] sendElement:[IQPacketManager createJoinMUCPacket:groupInvite.chat_id lastTimeActive:BEGINNING_OF_TIME]];
    
    NSLog(@"Accepted: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_JOINED chatID:groupInvite.chat_id];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon];
}

- (void)declineInvitation:(NSIndexPath *)indexPath {
    ChatMO*groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:groupInvite.chat_id]];
    
    NSLog(@"Declined: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_REQUEST_REJECTED chatID:groupInvite.chat_id];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon];
}

- (void)acceptFriendRequest:(NSIndexPath *)indexPath {
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    NSMutableString *address = [NSMutableString stringWithFormat:@"%@@%@", friendRequest.username, [ConnectionProvider getServerIPAddress]];
    [[self.cp getConnection] sendElement:[IQPacketManager createSubscribedPacket:friendRequest.username]];
    [[self.cp getConnection] sendElement:[IQPacketManager createForceCreateRosterEntryPacket:address]];
    [FriendsDBManager updateUserSetStatusFriends:friendRequest.username];
    
    NSLog(@"Accepted friend request: %@, %@", address, friendRequest.username);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon];
}

- (void)declineFriendRequest:(NSIndexPath *)indexPath {
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    [FriendsDBManager updateUserSetStatusRejected:friendRequest.username];
    
    NSLog(@"Declined friend request: %@", friendRequest.name);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon];
}

-(void)handleGetLastPacketReceived:(NSNotification*)notification {
    self.groupChats = [ChatDBManager getAllActiveGroupChats];
    self.oneToOneChats = [ChatDBManager getAllOneToOneChats];
    [self.tableView reloadData];
}

-(void)handleRefreshListView:(NSNotification*)notification {
    self.groupChats = [ChatDBManager getAllActiveGroupChats];
    self.oneToOneChats = [ChatDBManager getAllOneToOneChats];
    [self.tableView reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    }
    else {
        NSLog(@"long press on table view at row %d", indexPath.row);
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self handleLongPressForRowAtIndexPath:indexPath];
        }
    }
}

-(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        _editingChat = [_groupChats objectAtIndex:indexPath.row];
    } else {
        _editingChat = [_oneToOneChats objectAtIndex:indexPath.row];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Conversation" message:@"Enter a new name for this conversation." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"Setting Chat Name Here");
        NSString *name = [alertView textFieldAtIndex:0].text;
        [_editingChat setUser_defined_chat_name:name];
        [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
        [_tableView reloadData];
    }
    _editingChat = nil;
}

@end
