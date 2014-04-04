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
@property (strong, nonatomic) NSMutableArray *groupChats;
@property (strong, nonatomic) NSMutableArray *oneToOneChats;
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
@property (strong, nonatomic) MessageMO *mostRecentMessageInPushedChat;
@property (strong, nonatomic) UIView *greyOutView;
@property (strong, nonatomic) ChatMO *editingChat;
@property (nonatomic) CGFloat notificationHeight;
@property (nonatomic) CGFloat notificationCenter;

@end

@implementation DashboardViewController

static BOOL notificationsHalfHidden = NO;

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView) name:PACKET_ID_GET_VCARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications) name:NOTIFICATION_UPDATE_NOTIFICATIONS object:nil];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.cp = [ConnectionProvider getInstance];
    
    [self.header setFont:[StyleManager getFontStyleMediumSizeXL]];
    [self.header setTextColor:[UIColor whiteColor]];
    [self.footerView setFont:[StyleManager getFontStyleLightSizeXL]];
    
    
    self.groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    self.oneToOneChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveOneToOneChats]];
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
    
    _greyOutView = [[UIView alloc] initWithFrame:CGRectZero];
    [_greyOutView setUserInteractionEnabled:NO];
    [_greyOutView setBackgroundColor:[UIColor blackColor]];
    [_greyOutView setAlpha:0.0];
    [self.view addSubview:_greyOutView];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([tableView isEqual:_tableView]) {
        if (section == 0) {
            return nil;
        }
        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
        [footer setBackgroundColor:[UIColor clearColor]];
        return footer;
    } else {
        /*UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.0f)];
        [footer setBackgroundColor:[UIColor blackColor]];
        UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpToHideNotifications:)];
        [swipeUpGestureRecognizer setDelegate:self];
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [footer addGestureRecognizer:swipeUpGestureRecognizer];
        return footer;*/
        return nil;
    }
}

- (void)handleSwipeUpToHideNotifications:(UIGestureRecognizer *)gestureRecognizer {
    [self hideNotifications];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Should Begin?");
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    NSLog(@"Gesture 1: %@ Gesture 2: %@", [gestureRecognizer description], [otherGestureRecognizer description]);
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView isEqual:_tableView]) {
        return section;
    }
    return 0;
}

-(void)handleGroupChatMovedToTop:(NSNotification *)notification {
    
}

-(void)handleOneToOneChatMovedToTop:(NSNotification *)notification {
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_clickedCellIndexPath != nil) {
        ChatMO *chat = (_clickedCellIndexPath.section == 0) ? [_groupChats objectAtIndex:_clickedCellIndexPath.row] : [_oneToOneChats objectAtIndex:_clickedCellIndexPath.row];
        MessageMO *message = [[chat messages] lastObject];
        if (![message.time isEqualToString:_mostRecentMessageInPushedChat.time]) {
            if (_clickedCellIndexPath.section == 0) {
                [_groupChats removeObjectAtIndex:_clickedCellIndexPath.row];
                [_groupChats insertObject:chat atIndex:0];
            } else {
                [_oneToOneChats removeObjectAtIndex:_clickedCellIndexPath.row];
                [_oneToOneChats insertObject:chat atIndex:0];
            }
        }
        [_tableView reloadData];
    }
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
        _mostRecentMessageInPushedChat = [[dest.chatMO messages] lastObject];
    } else if([segue.identifier compare:SEGUE_ID_ONE_TO_ONE_CONVERSATION] == 0) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        dest.chatMO = [self.oneToOneChats objectAtIndex:self.clickedCellIndexPath.row];
        _mostRecentMessageInPushedChat = [[dest.chatMO messages] lastObject];
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
        
        [cell.textLabel setTextColor:[StyleManager getColorBlue]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.detailTextLabel setHidden:NO];
        
        ChatMO *chatMo;
        if(indexPath.section == 0) {
            chatMo = [self.groupChats objectAtIndex:indexPath.row];
        } else {
            chatMo = [self.oneToOneChats objectAtIndex:indexPath.row];
        }
        
        [cell.textLabel setText:[chatMo getChatName]];
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
        
        //SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        /*if (cell == nil) {
            cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier containingTableView:self.notificationTableView leftUtilityButtons:nil rightUtilityButtons:[self notificationsButtons]];
            cell.delegate = self;
        }*/
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        CGFloat buttonSize = 30.0f, padding = 5.0f;
        
        UIButton *accept = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - 4*padding - 2*buttonSize, (cell.frame.size.height-buttonSize)/2, buttonSize, buttonSize)];
        [accept setImage:[UIImage imageNamed:@"check-icon-green-square.png"] forState:UIControlStateNormal];
        
        UIButton *decline = [[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width - padding - buttonSize, (cell.frame.size.height-(buttonSize-5))/2, buttonSize-5, buttonSize-5)];
        [decline setImage:[UIImage imageNamed:@"x-green.png"] forState:UIControlStateNormal];
        
        NSLog(@"Cell: %@", [cell description]);
        
        if (indexPath.section == 0) {
            ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
            //cell.textLabel.text = groupInvite.chat_name;
            NSString *inviter = [FriendsDBManager getUserWithJID:groupInvite.owner_id].name;
            //cell.textLabel.text = [NSMutableString stringWithFormat:@"%@ - invited by %@", groupInvite.chat_name, inviter];
            cell.textLabel.text = groupInvite.chat_name;
            cell.detailTextLabel.text = [NSMutableString stringWithFormat:@"invited by %@", inviter];
            [accept addTarget:self action:@selector(acceptInvitation:) forControlEvents:UIControlEventTouchUpInside];
            [decline addTarget:self action:@selector(declineInvitation:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
            cell.textLabel.text = friendRequest.name;
            [accept addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            [decline addTarget:self action:@selector(declineFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell.textLabel setFont:[StyleManager getFontStyleBoldSizeLarge]];
        [cell.textLabel setTextColor:[StyleManager getColorGreen]];
        [cell.detailTextLabel setFont:[StyleManager getFontStyleLightSizeSmall]];
        [cell.detailTextLabel setTextColor:[UIColor blackColor]];
        [cell.contentView addSubview:accept];
        [cell.contentView addSubview:decline];
        
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
        NSLog(@"Deleting Chat! %@", chat);
        if (indexPath.section == 0) {
            [_groupChats removeObject:chat];
        } else {
            [_oneToOneChats removeObject:chat];
        }
        [[self.cp getConnection] sendElement:[IQPacketManager createLeaveChatPacket:chat.chat_id]];
        [MessagesDBManager deleteMessagesFromChatWithID:chat.chat_id];
        [ChatDBManager deleteChat:chat];
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

-(void)notificationSwipeClose:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe");
    [self hideNotifications];
}

- (void) showNotifications {
    NSLog(@"Show Notifications");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLE_SWIPE object:nil];
    
    CGRect notificationFrame = CGRectMake(0, 0, self.view.frame.size.width, _notificationHeight);
    
    self.notificationTableView.hidden = NO;
    self.greyOutView.frame = self.view.frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.greyOutView.alpha = 0.5;
                         self.notificationTableView.frame = notificationFrame;
                         _notificationCenter = self.notificationTableView.center.y;
                         [self.tableView setBackgroundView:nil];
                     }
                     completion:^(BOOL finished){
                         [self.tableView setUserInteractionEnabled:NO];
                     }];
    [UIView commitAnimations];
}

- (void) hideNotifications {
    NSLog(@"Hide Notifications");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_SWIPE object:nil];
    
    self.groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    [self.tableView reloadData];
    
    notificationsHalfHidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.greyOutView.alpha = 0;
                         self.notificationTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
                     }
                     completion:^(BOOL finished){
                         self.greyOutView.frame = CGRectZero;
                         self.notificationTableView.hidden = YES;
                         [self.tableView setUserInteractionEnabled:YES];
                     }];
    [UIView commitAnimations];
}

-(IBAction)hideNotificationsGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.view];
    
    if (!CGRectContainsPoint(self.notificationTableView.frame, tapLocation) && !self.notificationTableView.hidden) {
        [self hideNotifications];
    }
}

-(void)adjustAnchorPoint:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint inView = [recognizer locationInView:recognizer.view];
        CGPoint inSuperview = [recognizer locationInView:recognizer.view.superview];
        
        recognizer.view.layer.anchorPoint = CGPointMake(inView.x / recognizer.view.bounds.size.width, inView.y / recognizer.view.bounds.size.height);
        recognizer.view.center = inSuperview;
    }
}

/*-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.notificationTableView) {
        NSLog(@"Velocity: %f,%f Offset: %f,%f", velocity.x, velocity.y, targetContentOffset->x, targetContentOffset->y);
        NSLog(@"Current Offset: %f", scrollView.contentOffset.y);
        if (scrollView.contentOffset.y > 60) {
            [self hideNotifications];
        }
    }
}*/

/*-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _notificationTableView) {
        if (scrollView.contentOffset.y > 60) {
            [self hideNotifications];
        } else {
        [_notificationTableView setFrame:CGRectMake(0, 0, _notificationTableView.frame.size.width, _notificationTableView.frame.size.height - scrollView.contentOffset.y)];
        }
    }
}*/

-(void)setNotificationsIcon {
    NSMutableString *imageName;
    NSMutableString *greenImageName;
    if ([self.friendRequests count] + [self.groupInvites count] > 0 && [self.friendRequests count] + [self.groupInvites count] < 6) {
        imageName = [NSMutableString stringWithFormat:@"notification%d.png", [self.friendRequests count] + [self.groupInvites count]];
        //greenImageName = [NSMutableString stringWithFormat:@"notification%d-green.png", [self.friendRequests count] + [self.groupInvites count]];
    } else if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        imageName = [NSMutableString stringWithString:@"notification-none.png"];
        //greenImageName = [NSMutableString stringWithString:@"arrow-close-notifications.png"];
    } else {
        imageName = [NSMutableString stringWithString:@"notification5+.png"];
        //greenImageName = [NSMutableString stringWithString:@"notification5+-green.png"];
    }
    UIImage *notificationsImage = [UIImage imageNamed:imageName];
    UIImageView *notificationsBadgeGreen = [[UIImageView alloc] initWithFrame:CGRectMake(281, 27, 24, 24)];
    [self.notificationsButton setImage:notificationsImage forState:UIControlStateNormal];
    greenImageName = [NSMutableString stringWithString:@"arrow-close-notifications.png"];
    UIImage *notificationsImageGreen = [UIImage imageNamed:greenImageName];
    [notificationsBadgeGreen setImage:notificationsImageGreen];
    self.notificationsButtonGreen = [[UIButton alloc] initWithFrame:CGRectMake(281, 27, 24, 24)];
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideNotificationsGesture:)];
    tapRecognizer.delaysTouchesEnded = YES;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideNotificationsGesture:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    swipeRecognizer.numberOfTouchesRequired = 1;
    swipeRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipeRecognizer];
    
    self.notificationTableView = [[UITableView alloc] init];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
    [self.notificationTableView setTableHeaderView:self.notificationsHeader];
    [self.notificationTableView setSeparatorColor:[StyleManager getColorGreen]];
    [self setNotificationSize];
    
    [self.view addSubview:self.notificationTableView];
    
    [self hideNotifications];
}

-(void)setNotificationSize {
    if (self.groupInvites.count + self.friendRequests.count == 0) {
        _notificationHeight = self.view.frame.size.height/2;
    } else {
        if (self.groupInvites.count == 0 || self.friendRequests.count == 0) {
            _notificationHeight = self.notificationTableView.rowHeight*(self.groupInvites.count + self.friendRequests.count) + self.notificationTableView.sectionHeaderHeight + self.notificationsHeader.frame.size.height;
        } else {
        _notificationHeight = self.notificationTableView.rowHeight*(self.groupInvites.count + self.friendRequests.count) + self.notificationTableView.numberOfSections*self.notificationTableView.sectionHeaderHeight + self.notificationsHeader.frame.size.height;
        }
    }
    self.notificationTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, _notificationHeight);
}

- (void)updateNotifications {
    _groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    _friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    [self.notificationTableView reloadData];
    [self setNotificationsIcon];
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:groupInvite.chat_id]];
    [[self.cp getConnection] sendElement:[IQPacketManager createJoinMUCPacket:groupInvite.chat_id lastTimeActive:BEGINNING_OF_TIME]];
    
    NSLog(@"Accepted: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_JOINED chatID:groupInvite.chat_id];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationSize];
    [self setNotificationsIcon];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    ChatMO*groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:groupInvite.chat_id]];
    
    NSLog(@"Declined: %@", groupInvite.chat_id);
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_REQUEST_REJECTED chatID:groupInvite.chat_id];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationSize];
    [self setNotificationsIcon];
}

- (IBAction)acceptFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    NSMutableString *address = [NSMutableString stringWithFormat:@"%@@%@", friendRequest.username, [ConnectionProvider getServerIPAddress]];
    [[self.cp getConnection] sendElement:[IQPacketManager createSubscribedPacket:friendRequest.username]];
    [[self.cp getConnection] sendElement:[IQPacketManager createForceCreateRosterEntryPacket:address]];
    [FriendsDBManager updateUserSetStatusFriends:friendRequest.username];
    
    NSLog(@"Accepted friend request: %@, %@", address, friendRequest.username);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationSize];
    [self setNotificationsIcon];
}

- (IBAction)declineFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    [FriendsDBManager updateUserSetStatusRejected:friendRequest.username];
    
    NSLog(@"Declined friend request: %@", friendRequest.name);
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationSize];
    [self setNotificationsIcon];
}

-(void)handleRefreshListView {
    self.groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    self.oneToOneChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllOneToOneChats]];
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
