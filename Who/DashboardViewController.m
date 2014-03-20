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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
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
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            NSLog(@"created cell when null");
        }
        
        UIButton *accept = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        accept.frame = CGRectMake(200.0f, 5.0f, 30.0f, 30.0f);
        [accept setTitle:INVITATION_ACCEPT forState:UIControlStateNormal];
        [cell.contentView addSubview:accept];
        
        UIButton *decline = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        decline.frame = CGRectMake(240.0f, 5.0f, 30.0f, 30.0f);
        [decline setTitle:INVITATION_DECLINE forState:UIControlStateNormal];
        [cell.contentView addSubview:decline];
        
        NSLog(@"Cell: %@", [cell description]);
        
        if (indexPath.section == 0) {
            NSDictionary *notification = [self.groupInvites objectAtIndex:indexPath.row];
            cell.textLabel.text = [notification objectForKey:@"chatName"];
            [accept addTarget:self action:@selector(acceptInvitation:) forControlEvents:UIControlEventTouchUpInside];
            [decline addTarget:self action:@selector(declineInvitation:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
            cell.textLabel.text = friendRequest.name;
            [accept addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            [decline addTarget:self action:@selector(declineFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell.textLabel setFont:[StyleManager getFontStyleLightSizeMed]];
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

-(void)loadNotifications:(NSNotification *)notification {
    NSLog(@"Load notifications");
    
    self.friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    self.groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingActiveGroupChats]];
    
    NSMutableString *imageName;
    if ([self.friendRequests count] + [self.groupInvites count] < 6) {
        imageName = [NSMutableString stringWithFormat:@"notification%lu.png", [self.friendRequests count] + [self.groupInvites count]];
    } else {
        imageName = [NSMutableString stringWithString:@"notification5+.png"];
    }
    UIImage *notificationsCount = [UIImage imageNamed:imageName];
    [self.notificationsButton setImage:notificationsCount forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideNotifications:)];
    tapRecognizer.delaysTouchesEnded = YES;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.5)];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 280, 21)];
    [notificationsLabel setText:@"Notifications"];
    [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
    [notificationsLabel setFont:[StyleManager getFontStyleLightSizeXL]];
    [notificationsLabel setTextColor:[StyleManager getColorGreen]];
    [header addSubview:notificationsLabel];
    UIImageView *notificationsBadge = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25, 30, 30)];
    UIImage *notificationsImage = [UIImage imageNamed:@"notifications1.png"];
    [notificationsBadge setImage:notificationsImage];
    [header addSubview:notificationsBadge];
    
    [self.notificationTableView setTableHeaderView:header];
    [self.notificationTableView setSeparatorColor:[StyleManager getColorGreen]];
    
    [self.view addSubview:self.notificationTableView];
    [self hideNotifications];
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Accepted: %@", [notification objectForKey:@"chatId"]);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Declined: %@", [notification objectForKey:@"chatId"]);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)acceptFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send accept request packet
    
    NSLog(@"Accepted friend request: %@", friendRequest.name);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send deny request packet
    
    NSLog(@"Declined friend request: %@", friendRequest.name);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
