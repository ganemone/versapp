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
@property (strong, nonatomic) UIView *notificationsHeader;
@property (strong, nonatomic) UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *friendRequests;
@property (strong, nonatomic) NSMutableArray *groupInvites;

@end

@implementation DashboardViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetLastPacketReceived:) name:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:PACKET_ID_GET_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    /*UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setImage:[UIImage imageNamed:@"grad-back-messages.jpg"]];*/
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    //[self.tableView setBackgroundView:backgroundImageView];
    //[self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.cp = [ConnectionProvider getInstance];
    
    [self.header setFont:[StyleManager getFontStyleLightSizeXL]];
    [self.header setTextColor:[UIColor whiteColor]];
    [self.footerView setFont:[StyleManager getFontStyleLightSizeXL]];
    
    self.groupChats = [ChatDBManager getAllGroupChats];
    self.oneToOneChats = [ChatDBManager getAllOneToOneChats];
    
    [self loadNotifications];

}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
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
    return 2;
}

/*-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0f, self.view.frame.size.width, 30.0)];
    [customView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grad-back-messages.jpg"]]];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    [headerLabel setFont:[StyleManager getFontStyleLightSizeMed]];
    headerLabel.frame = CGRectMake(10.0f, 10.0f, self.view.frame.size.width, 30.0);
    
    if (section == 0) {
        headerLabel.text = @"Groups";
    } else {
        headerLabel.text = @"One to One";
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}*/

/*-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}*/

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return (section == 0) ? @"Groups" : @"One to One";
    } else {
        if (section == 0)
            return NOTIFICATIONS_GROUP;
        else
            return NOTIFICATIONS_FRIEND;
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
        
        [cell.textLabel setText:chatMo.user_defined_chat_name];
        [cell.detailTextLabel setText:[chatMo getLastMessage]];
        
        if ([ChatDBManager doesChatHaveNewMessage:chatMo.chat_id]) {
            [cell.textLabel setFont:[StyleManager getFontStyleBoldSizeLarge]];
            [cell.detailTextLabel setFont:[StyleManager getFontStyleBoldSizeMed]];
        } else {
            [cell.textLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
            [cell.detailTextLabel setFont:[StyleManager getFontStyleLightSizeMed]];
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    } else {
        static NSString *cellIdentifier = @"Cell";
        
        SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier containingTableView:self.notificationTableView leftUtilityButtons:nil rightUtilityButtons:[self notificationsButtons]];
            cell.delegate = self;
        }
        
        NSLog(@"Cell: %@", [cell description]);
        
        if (indexPath.section == 0) {
            ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
            cell.textLabel.text = groupInvite.chat_name;
        } else {
            FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
            cell.textLabel.text = friendRequest.name;
        }
        
        [cell.textLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
        [cell.textLabel setTextColor:[StyleManager getColorGreen]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.clickedCellIndexPath = indexPath;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:SEGUE_ID_GROUP_CONVERSATION sender:self];
    } else {
        [self performSegueWithIdentifier:SEGUE_ID_ONE_TO_ONE_CONVERSATION sender:self];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if(section == 0) {
            return self.groupChats.count;
        } else {
            return self.oneToOneChats.count;
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
                         
                     }];
    [UIView commitAnimations];
}

- (void) hideNotifications {
    NSLog(@"Hide Notifications");
    
    CGRect notificationFrame = self.notificationTableView.frame;
    notificationFrame.origin.y = -1*self.notificationTableView.frame.size.height;
    //notificationFrame.origin.y = self.view.frame.size.height;
    
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
        imageName = [NSMutableString stringWithFormat:@"notification%lu.png", [self.friendRequests count] + [self.groupInvites count]];
        greenImageName = [NSMutableString stringWithFormat:@"notification%lu-green.png", [self.friendRequests count] + [self.groupInvites count]];
    } else if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        imageName = [NSMutableString stringWithString:@"notification-none.png"];
        greenImageName = [NSMutableString stringWithString:@"notification-none-green.png"];
    } else {
        imageName = [NSMutableString stringWithString:@"notification5+.png"];
        greenImageName = [NSMutableString stringWithString:@"notification5+-green.png"];
    }
    UIImage *notificationsImage = [UIImage imageNamed:imageName];
    UIImageView *notificationsBadgeGreen = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 30, 30)];
    [self.notificationsButton setImage:notificationsImage forState:UIControlStateNormal];
    UIImage *notificationsImageGreen = [UIImage imageNamed:greenImageName];
    [notificationsBadgeGreen setImage:notificationsImageGreen];
    
    self.notificationsHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 280, 21)];
    [notificationsLabel setText:@"Notifications"];
    [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
    [notificationsLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [notificationsLabel setTextColor:[StyleManager getColorGreen]];
    [self.notificationsHeader addSubview:notificationsLabel];
    [self.notificationsHeader addSubview:notificationsBadgeGreen];
}

-(void)loadNotifications {
    NSLog(@"Load notifications");
    
    self.groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    self.friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];

    self.friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    self.groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    
    NSLog(@"group invites: %@", self.groupInvites);
    NSLog(@"friend requests: %@", self.friendRequests);
    
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
    
    /*UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 280, 21)];
    [notificationsLabel setText:@"Notifications"];
    [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
    [notificationsLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [notificationsLabel setTextColor:[StyleManager getColorGreen]];
    [header addSubview:notificationsLabel];
    //UIImageView *notificationsBadge = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 30, 30)];
    //[notificationsBadge setImage:self.notificationsImageGreen];
    [header addSubview:self.notificationsBadgeGreen];*/
    
    [self.notificationTableView setTableHeaderView:self.notificationsHeader];
    [self.notificationTableView setSeparatorColor:[StyleManager getColorGreen]];
    
    [self.view addSubview:self.notificationTableView];
    [self hideNotifications];
}

- (IBAction)acceptInvitation:(NSIndexPath *)indexPath {
    ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:groupInvite.chat_id]];
    
    NSLog(@"Accepted: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self setNotificationsIcon];
}

- (IBAction)declineInvitation:(NSIndexPath *)indexPath {
    ChatMO*groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:groupInvite.chat_id]];
    
    NSLog(@"Declined: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self setNotificationsIcon];
}

- (IBAction)acceptFriendRequest:(NSIndexPath *)indexPath {
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    NSMutableString *address = [NSMutableString stringWithFormat:@"%@@%@", friendRequest.username, [ConnectionProvider getServerIPAddress]];
    [[self.cp getConnection] sendElement:[IQPacketManager createForceCreateRosterEntryPacket:address]];
    [[self.cp getConnection] sendElement:[IQPacketManager createSubscribedPacket:friendRequest.username]];
    
    [FriendsDBManager updateUserSetStatusFriends:friendRequest.username];
    
    NSLog(@"Accepted friend request: %@, %@", address, friendRequest.username);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self setNotificationsIcon];
}

- (IBAction)declineFriendRequest:(NSIndexPath *)indexPath {
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    [FriendsDBManager updateUserSetStatusRejected:friendRequest.username];
    
    NSLog(@"Declined friend request: %@", friendRequest.name);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self setNotificationsIcon];
}

-(void)handleGetLastPacketReceived:(NSNotification*)notification {
    self.groupChats = [ChatDBManager getAllGroupChats];
    self.oneToOneChats = [ChatDBManager getAllOneToOneChats];
    [self.tableView reloadData];
}

-(void)handleRefreshListView:(NSNotification*)notification {
    self.groupChats = [ChatDBManager getAllGroupChats];
    self.oneToOneChats = [ChatDBManager getAllOneToOneChats];
    [self.tableView reloadData];
}

@end
