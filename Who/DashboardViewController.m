//
//  DashboardViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardTableViewCell.h"
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
#import "UserDefaultManager.h"
#import "WSCoachMarksView.h"
#import "MBProgressHUD.h"

#define footerSize 25

@interface DashboardViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSString *timeLastActive;
@property (strong, nonatomic) NSIndexPath *clickedCellIndexPath;
@property (strong, nonatomic) NSMutableArray *groupChats;
@property (strong, nonatomic) NSMutableArray *oneToOneChats;
@property (strong, nonatomic) NSMutableArray *thoughtChats;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UIButton *notificationsButton;
@property (strong, nonatomic) UIButton *notificationsButtonGreen;
@property (strong, nonatomic) UIView *notificationsHeader;
@property (strong, nonatomic) UIView *notificationsFooter;
@property (strong, nonatomic) UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *friendRequests;
@property (strong, nonatomic) NSMutableArray *groupInvites;
@property (strong, nonatomic) MessageMO *mostRecentMessageInPushedChat;
@property (strong, nonatomic) UIView *greyOutView;
@property (strong, nonatomic) ChatMO *editingChat;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (nonatomic) CGFloat notificationHeight;
@property (strong, nonatomic) CustomIOS7AlertView *reportAlertView;

@property (weak, nonatomic) IBOutlet UIView *noConversationsDarkView;
@property (weak, nonatomic) IBOutlet UIView *noConversationsView;
@property (weak, nonatomic) IBOutlet UITextView *noConversationsTextView;

@end

@implementation DashboardViewController

static BOOL notificationsHalfHidden = NO;

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"View Will Appear");
    if ([UserDefaultManager hasLoggedIn] == NO) {
        [UserDefaultManager setLoggedInTrue];
        [[[UIAlertView alloc] initWithTitle:@"Welcome to Versapp" message:@"We will guide you through all of Versapps features. This page is your message dashboard. All of your conversations will appear here. Swipe to checkout the other screens." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    if ([self.tableView numberOfRowsInSection:0] + [self.tableView numberOfRowsInSection:1] + [self.tableView numberOfRowsInSection:2] == 0)
    {
        [self showNoConversationsView];
    }
    else
    {
        if (![UserDefaultManager hasSeenConversation]) {
            [UserDefaultManager setSeenConversationTrue];
            [self doTutorial];
        }
        [self hideNoConfersationsView];
    }
}

-(void)doTutorial {
    CGFloat cellY;
    NSString *chatType;
    if ([_groupChats count] > 0) {
        cellY = _headerView.frame.size.height + 22.0f;
        chatType = @"group chat";
    } else if([_oneToOneChats count] > 0) {
        cellY = _headerView.frame.size.height + 44.0f;
        chatType = @"one to one";
    } else {
        cellY = _headerView.frame.size.height + 66.0f;
        chatType = @"thought chat";
    }
    
    CGRect cellFrame = CGRectMake(0, cellY, self.view.frame.size.width, 44.0f);
    CGRect imageRect = CGRectMake(5, cellY, 50, 44.0f);
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:cellFrame],
                                @"caption": @"Congrats! You are now in your first conversation."
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:imageRect],
                                @"caption": @"This icon will tell you what type of conversation it is."
                                },
                            
                            @{
                                @"rect": [NSValue valueWithCGRect:cellFrame],
                                @"caption": @"Long press on chats of any type for more options."
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    [self.view addSubview:coachMarksView];
    [self.view bringSubviewToFront:coachMarksView];
    [coachMarksView start];
}

-(void)viewDidLoad {
    NSLog(@"View did Load");
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [defaultCenter addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    [defaultCenter addObserver:self selector:@selector(handleRefreshListView) name:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
    [defaultCenter addObserver:self selector:@selector(handleRefreshListView) name:PACKET_ID_GET_VCARD object:nil];
    [defaultCenter addObserver:self selector:@selector(loadNotifications) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    [defaultCenter addObserver:self selector:@selector(updateNotifications) name:NOTIFICATION_UPDATE_NOTIFICATIONS object:nil];
    [defaultCenter addObserver:self selector:@selector(handleShowLoadingMessages) name:NOTIFICATION_SHOW_LOADING object:nil];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.cp = [ConnectionProvider getInstance];
    
    [self.header setFont:[StyleManager getFontStyleLightSizeHeader]];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [_tableView addGestureRecognizer:lpgr];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [imageView setClipsToBounds:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    [imageView setImage:[UIImage imageNamed:@"messages-background-large.png"]];
    [self.tableView setBackgroundView:imageView];
    
    _reportAlertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Bullying", @"Self Harm", @"Spam", @"Inappropriate", @"Cancel", nil]];
    [_reportAlertView setDelegate:self];
    
    self.notificationTableView = [[UITableView alloc] init];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
    [self.notificationTableView setSeparatorColor:[StyleManager getColorGreen]];
    [self.notificationTableView setBackgroundColor:[UIColor whiteColor]];
    
    _notificationsFooter = [[UIView alloc] init];
    [_notificationsFooter setBackgroundColor:[UIColor blackColor]];
    [_notificationsFooter setAlpha:0.3];
    UIImageView *footerHandle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification-none"]];
    [footerHandle setFrame:CGRectMake(self.view.frame.size.width/2 - 10, 0, 20, 20)];
    [_notificationsFooter addSubview:footerHandle];
    _notificationsFooter.hidden = YES;
    [self.view addSubview:_notificationsFooter];
    
    _greyOutView = [[UIView alloc] initWithFrame:CGRectZero];
    [_greyOutView setUserInteractionEnabled:NO];
    [_greyOutView setBackgroundColor:[UIColor blackColor]];
    [_greyOutView setAlpha:0.0];
    
    [self.view addSubview:_greyOutView];
    [self.view bringSubviewToFront:self.notificationTableView];
    [self loadNotifications];
    
    [self.noConversationsTextView setFont:[StyleManager getFontStyleRegularSizeLarge]];
    
    [self.noConversationsDarkView setFrame:CGRectMake(0, self.headerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.headerView.frame.size.height)];
    [self.noConversationsView setFrame:_noConversationsDarkView.frame];
    
    [_notificationTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - footerSize)];
    
}

- (void)handleShowLoadingMessages
{
    NSLog(@"Going to show view");
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progress setLabelText:@"Loading Messages"];
    [progress setLabelFont:[StyleManager getFontStyleLightSizeXL]];
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //NSLog(@"Hiding HUD inside dispatch after");
        //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //});
}

- (void)showNoConversationsView
{
    [UIView animateWithDuration:0.5 animations:^{
        _noConversationsDarkView.hidden = NO;
        _noConversationsView.hidden = NO;
        [self.view bringSubviewToFront:_noConversationsDarkView];
        [self.view bringSubviewToFront:_noConversationsView];
        [self.view bringSubviewToFront:self.notificationTableView];
    }];
}

- (void)hideNoConfersationsView
{
    [UIView animateWithDuration:0.5 animations:^{
        _noConversationsDarkView.hidden = YES;
        _noConversationsView.hidden = YES;
        [self.view sendSubviewToBack:_noConversationsDarkView];
        [self.view sendSubviewToBack:_noConversationsView];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint scrollToPoint = [recognizer translationInView:_notificationTableView.tableFooterView];
    if (scrollToPoint.y + _notificationTableView.frame.origin.y + _notificationTableView.frame.size.height < self.view.frame.size.height*0.5) {
        [_notificationTableView setCenter:CGPointMake(_notificationTableView.center.x, _notificationTableView.center.y + scrollToPoint.y)];
        [_notificationsFooter setCenter:CGPointMake(_notificationsFooter.center.x, _notificationsFooter.center.y + scrollToPoint.y)];
        [recognizer setTranslation:CGPointMake(0, 0) inView:_notificationTableView.tableFooterView];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded && _notificationTableView.frame.origin.y < self.view.frame.size.height*0.25) {
        [self hideNotifications];
    }
}

- (void)handleSwipeUpToHideNotifications:(UIGestureRecognizer *)gestureRecognizer {
    [self hideNotifications];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:_tableView] && [self tableView:_tableView numberOfRowsInSection:0] == 0 && [self tableView:_tableView numberOfRowsInSection:1] == 0) {
        return 0;
    }
    return UITableViewAutomaticDimension;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    _oneToOneChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveOneToOneChats]];
    _thoughtChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllThoughtChats]];
    _friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    _groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    if ([_oneToOneChats count] > 0 || [_groupChats count] > 0) {
        [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    [self setNotificationsIcon:NO];
    [_notificationTableView reloadData];
    [_tableView reloadData];
    _clickedCellIndexPath = nil;
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

/*- (IBAction)toggleEditing:(id)sender {
 UIButton *button = (UIButton*)sender;
 if ([_tableView isEditing]) {
 [button setTitle:@"" forState:UIControlStateNormal];
 [button setImage:[UIImage imageNamed:@"trash-icon-blue.png"] forState:UIControlStateNormal];
 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLE_DASHBOARD_EDITING object:nil];
 [_tableView setEditing:NO animated:YES];
 } else {
 [button setImage:[UIImage imageNamed:@"x-blue.png"] forState:UIControlStateNormal];
 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_DASHBOARD_EDITING object:nil];
 [_tableView setEditing:YES animated:YES];
 }
 }*/


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SEGUE_ID_GROUP_CONVERSATION]) {
        ConversationViewController *dest = segue.destinationViewController;
        dest.chatMO = [[self groupChats] objectAtIndex:self.clickedCellIndexPath.row];
        _mostRecentMessageInPushedChat = [[dest.chatMO messages] lastObject];
    } else if([segue.identifier isEqualToString:SEGUE_ID_ONE_TO_ONE_CONVERSATION]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        if (self.clickedCellIndexPath.section == 1) {
            dest.chatMO = [self.oneToOneChats objectAtIndex:self.clickedCellIndexPath.row];
        } else {
            dest.chatMO = [self.thoughtChats objectAtIndex:self.clickedCellIndexPath.row];
        }
        _mostRecentMessageInPushedChat = [[dest.chatMO messages] lastObject];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return 3;
    } else {
        return 2;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        switch (section) {
            case 0: return @"Groups";
            case 1: return @"One-to-One";
            default: return @"Thoughts";
        }
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
        ChatMO *chatMo;
        if(indexPath.section == 0) {
            chatMo = [self.groupChats objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            chatMo = [self.oneToOneChats objectAtIndex:indexPath.row];
        } else {
            chatMo = [self.thoughtChats objectAtIndex:indexPath.row];
        }
        
        DashboardTableViewCell *cell = (DashboardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:chatMo.chat_id];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DashboardTableViewCell" owner:self options:nil] firstObject];
            [cell setUpWithChatMO:chatMo];
        }
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
        
        if (indexPath.section == 0) {
            ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
            //cell.textLabel.text = groupInvite.chat_name;
            NSString *inviter = [FriendsDBManager getUserWithJID:groupInvite.owner_id].name;
            //cell.textLabel.text = [NSMutableString stringWithFormat:@"%@ - invited by %@", groupInvite.chat_name, inviter];
            cell.textLabel.text = groupInvite.chat_name;
            if (inviter != nil) {
                cell.detailTextLabel.text = [NSMutableString stringWithFormat:@"Invited by %@", inviter];
            }
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
        [cell setBackgroundColor:[UIColor whiteColor]];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        self.clickedCellIndexPath = indexPath;
        if (indexPath.section == 0) {
            [self performSegueWithIdentifier:SEGUE_ID_GROUP_CONVERSATION sender:self];
        } else {
            [self performSegueWithIdentifier:SEGUE_ID_ONE_TO_ONE_CONVERSATION sender:self];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

/*-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
 return @"Leave Chat";
 }
 
 -(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
 }*/

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChatMO *chat;
        if (indexPath.section == 0 && [_groupChats count] > indexPath.row) {
            chat = [_groupChats objectAtIndex:indexPath.row];
            [_groupChats removeObjectAtIndex:indexPath.row];
        } else if(indexPath.section == 1 && [_oneToOneChats count] > indexPath.row) {
            chat = [_oneToOneChats objectAtIndex:indexPath.row];
            [_oneToOneChats removeObjectAtIndex:indexPath.row];
        } else if(indexPath.section == 2 && [_thoughtChats count] > indexPath.row) {
            chat = [_thoughtChats objectAtIndex:indexPath.row];
            [_thoughtChats removeObjectAtIndex:indexPath.row];
        } else {
            return;
        }
        [[self.cp getConnection] sendElement:[IQPacketManager createLeaveChatPacket:chat.chat_id]];
        [MessagesDBManager deleteMessagesFromChatWithID:chat.chat_id];
        [ChatDBManager deleteChat:chat];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if(section == 0) {
            return [self.groupChats count];
        } else if(section == 1) {
            return [self.oneToOneChats count];
        } else {
            return [self.thoughtChats count];
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
    [self hideNotifications];
}

- (void) showNotifications {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DISABLE_SWIPE object:nil];
    
    CGRect notificationFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2 - footerSize);
    CGRect footerFrame = CGRectMake(0, self.view.frame.size.height/2 - footerSize, self.view.frame.size.width, footerSize);
    
    self.notificationTableView.hidden = NO;
    _notificationsFooter.hidden = NO;
    self.greyOutView.frame = self.view.frame;
    
    [UIView animateWithDuration:.5
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:3.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.greyOutView.alpha = 0.5;
                         self.notificationTableView.frame = notificationFrame;
                         _notificationsFooter.frame = footerFrame;
                     }
                     completion:^(BOOL finished){
                         [self.tableView setUserInteractionEnabled:NO];
                     }];
    [UIView commitAnimations];
}

- (void) hideNotifications {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_SWIPE object:nil];
    
    self.groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    if ([_oneToOneChats count] > 0 || [_groupChats count] > 0) {
        [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    [self.tableView reloadData];
    
    notificationsHalfHidden = NO;
    
    [UIView animateWithDuration:.5
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:1.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.greyOutView.alpha = 0;
                         self.notificationTableView.center = CGPointMake(_notificationTableView.center.x, -1 * _notificationTableView.frame.size.height/2);
                         _notificationsFooter.center = CGPointMake(_notificationsFooter.center.x, -1*footerSize);
                     }
                     completion:^(BOOL finished){
                         self.greyOutView.frame = CGRectZero;
                         self.notificationTableView.hidden = YES;
                         _notificationsFooter.hidden = YES;
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

/*-(void)adjustAnchorPoint:(UIPanGestureRecognizer *)recognizer {
 if (recognizer.state == UIGestureRecognizerStateBegan) {
 CGPoint inView = [recognizer locationInView:recognizer.view];
 CGPoint inSuperview = [recognizer locationInView:recognizer.view.superview];
 
 recognizer.view.layer.anchorPoint = CGPointMake(inView.x / recognizer.view.bounds.size.width, inView.y / recognizer.view.bounds.size.height);
 recognizer.view.center = inSuperview;
 }
 }*/

/*- (UIImage*)getBlurredImage {
 CGSize size = CGSizeMake(self.view.bounds.size.width, footerSize);
 
 UIGraphicsBeginImageContext(size);
 [self.view drawViewHierarchyInRect:CGRectMake(0, 100, self.view.bounds.size.width, footerSize) afterScreenUpdates:NO];
 UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 // Gaussian Blur
 image = [image applyLightEffect];
 
 return image;
 }*/

-(void)setNotificationsIcon:(BOOL)didAccept {
    
    if (didAccept && [_friendRequests count] + [_groupInvites count] == 0) {
        [self hideNotifications];
    }
    
    NSMutableString *imageName;
    NSMutableString *greenImageName;
    if ([self.friendRequests count] + [self.groupInvites count] > 0 && [self.friendRequests count] + [self.groupInvites count] < 6) {
        imageName = [NSMutableString stringWithFormat:@"notification%d.png", (int)([self.friendRequests count] + [self.groupInvites count])];
    } else if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        imageName = [NSMutableString stringWithString:@"notification-none.png"];
    } else {
        imageName = [NSMutableString stringWithString:@"notification5+.png"];
    }
    UIImage *notificationsImage = [UIImage imageNamed:imageName];
    [self.notificationsButton setImage:notificationsImage forState:UIControlStateNormal];
    [self.notificationsButton setContentEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    greenImageName = [NSMutableString stringWithString:@"arrow-close-notifications.png"];
    UIImage *notificationsImageGreen = [UIImage imageNamed:greenImageName];
    self.notificationsButtonGreen = [[UIButton alloc] initWithFrame:CGRectMake(275, 26, 30, 30)];
    [self.notificationsButtonGreen setImage:notificationsImageGreen forState:UIControlStateNormal];
    [self.notificationsButtonGreen addTarget:self action:@selector(notificationsGreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.friendRequests count] + [self.groupInvites count] == 0) {
        self.notificationsHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height*0.5 - footerSize)];
        UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*0.25, self.view.frame.size.width, 21)];
        [notificationsLabel setText:NO_NOTIFICATIONS];
        [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
        [notificationsLabel setFont:[StyleManager getFontStyleLightSizeXL]];
        [notificationsLabel setTextColor:[StyleManager getColorBlue]];
        [self.notificationsHeader addSubview:notificationsLabel];
        [self.notificationsHeader addSubview:self.notificationsButtonGreen];
        [self.notificationTableView setTableHeaderView:self.notificationsHeader];
    } else {
        self.notificationsHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 66)];
        UILabel *notificationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 32, 280, 21)];
        [notificationsLabel setText:NOTIFICATIONS];
        [notificationsLabel setTextAlignment:NSTextAlignmentCenter];
        [notificationsLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
        [notificationsLabel setTextColor:[StyleManager getColorBlue]];
        [self.notificationsHeader addSubview:notificationsLabel];
        [self.notificationsHeader addSubview:self.notificationsButtonGreen];
        [self.notificationsHeader setBackgroundColor:[UIColor whiteColor]];
    }
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_notificationsFooter addGestureRecognizer:pan];
    [[self.notificationTableView tableHeaderView] setBackgroundColor:[UIColor whiteColor]];
    [self.notificationTableView setTableHeaderView:self.notificationsHeader];
}

-(void)loadNotifications {
    
    self.groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    self.friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    [_notificationTableView setCenter:CGPointMake(_notificationTableView.center.x, -1 *_notificationHeight / 2)];
    [self setNotificationsIcon:NO];
    
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
    
    [self.view addSubview:self.notificationTableView];
    
    //[self hideNotifications];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ENABLE_SWIPE object:nil];
    
    self.groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    [self.tableView reloadData];
    
    notificationsHalfHidden = NO;
}

- (void)updateNotifications {
    _groupInvites = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllPendingGroupChats]];
    _friendRequests = [[NSMutableArray alloc] initWithArray:[FriendsDBManager getAllWithStatusPending]];
    [self.notificationTableView reloadData];
    [self setNotificationsIcon:NO];
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:groupInvite.chat_id]];
    [[self.cp getConnection] sendElement:[IQPacketManager createJoinMUCPacket:groupInvite.chat_id lastTimeActive:BEGINNING_OF_TIME]];
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_JOINED chatID:groupInvite.chat_id];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon:YES];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    ChatMO *groupInvite = [self.groupInvites objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:groupInvite.chat_id]];
    
    [self.groupInvites removeObjectAtIndex:indexPath.row];
    [ChatDBManager setChatStatus:STATUS_REQUEST_REJECTED chatID:groupInvite.chat_id];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon:YES];
}

- (IBAction)acceptFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    NSMutableString *address = [NSMutableString stringWithFormat:@"%@@%@", friendRequest.username, [ConnectionProvider getServerIPAddress]];
    [[self.cp getConnection] sendElement:[IQPacketManager createSubscribedPacket:friendRequest.username]];
    [[self.cp getConnection] sendElement:[IQPacketManager createForceCreateRosterEntryPacket:address]];
    [FriendsDBManager updateUserSetStatusFriends:friendRequest.username];
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon:YES];
}

- (IBAction)declineFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    FriendMO *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    [[self.cp getConnection] sendElement:[IQPacketManager createUnsubscribedPacket:friendRequest.username]];
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [[delegate managedObjectContext] deleteObject:friendRequest];
    [delegate saveContext];
    
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self setNotificationsIcon:YES];
}

-(void)handleRefreshListView {
    NSLog(@"Hiding HUDS in Refresh List View");
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    _groupChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllActiveGroupChats]];
    _oneToOneChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllOneToOneChats]];
    _thoughtChats = [[NSMutableArray alloc] initWithArray:[ChatDBManager getAllThoughtChats]];
    if ([_oneToOneChats count] > 0 || [_groupChats count] > 0) {
        [_tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
        [self hideNoConfersationsView];
    }
    [_tableView reloadData];
    [_notificationTableView reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
    }
    else {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self handleLongPressForRowAtIndexPath:indexPath];
        }
    }
}

-(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
    _editingIndexPath = indexPath;
    if (indexPath.section == 0) {
        _editingChat = [_groupChats objectAtIndex:indexPath.row];
        [self showGroupLongPressDialog];
    } else if(indexPath.section == 1) {
        _editingChat = [_oneToOneChats objectAtIndex:indexPath.row];
        [self showOneToOneLongPressDialog];
    } else {
        _editingChat = [_thoughtChats objectAtIndex:indexPath.row];
        [self showOneToOneLongPressDialog];
    }
}

- (void)showGroupLongPressDialog {
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename Chat", @"Leave Chat", nil];
    
    CustomIOS7AlertView *alertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Rename Chat", @"Leave Chat", @"Report Chat", @"Cancel", nil]];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)showOneToOneLongPressDialog {
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename Chat", @"Leave Chat", @"Block User", nil];
    
    CustomIOS7AlertView *alertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Rename Chat", @"Leave Chat", @"Block User", @"Report Chat", @"Cancel", nil]];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)showRenameDialog {
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename Conversation" message:@"Enter a new name for this conversation." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
    //[alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Rename Conversation" message:@"Enter a new name for this conversation." buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Rename", nil] hasInput:YES];
    [alertView setDelegate:self];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] == buttonIndex) {
        _editingChat = nil;
        return;
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rename Chat"]) {
        [self showRenameDialog];
    } /*else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rename"]) {
       [self handleRenameChat:alertView];
       }*/ else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave Chat"]) {
           //UIAlertView *leaveAlertView = [[UIAlertView alloc] initWithTitle:@"Leave Chat" message:@"Are you sure you want to leave this conversation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Leave", nil];
           //[leaveAlertView setAlertViewStyle:UIAlertViewStyleDefault];
           CustomIOS7AlertView *leaveAlertView = [StyleManager createCustomAlertView:@"Leave Chat" message:@"Are you sure you want to leave this conversation?" buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Leave", nil] hasInput:NO];
           [leaveAlertView setDelegate:self];
           [leaveAlertView show];
       } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Block User"]) {
           //[[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Blocking this user will not allow them to send you one to one messages anymore." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil] show];
           CustomIOS7AlertView *blockAlertView = [StyleManager createCustomAlertView:@"Are you sure?" message:@"Blocking this user will not allow them to send you one to one messages anymore." buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Block", nil] hasInput:NO];
           [blockAlertView setDelegate:self];
           [blockAlertView show];
       } /*else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Block"]) {
          [self handleBlockOneToOneChat];
          } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave"]) {
          [self handleLeaveChat];
          }*/
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rename Chat"]) {
        [self showRenameDialog];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Rename"]) {
        [self handleRenameChat:[alertView getInputText]];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave Chat"]) {
        CustomIOS7AlertView *leaveAlertView = [StyleManager createCustomAlertView:@"Leave Chat" message:@"Are you sure you want to leave this conversation?" buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Leave", nil] hasInput:NO];
        [leaveAlertView setDelegate:self];
        [leaveAlertView show];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Leave"]) {
        [self handleLeaveChat];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Block User"]) {
        //[[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Blocking this user will not allow them to send you one to one messages anymore." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil] show];
        CustomIOS7AlertView *blockAlertView = [StyleManager createCustomAlertView:@"Are you sure?" message:@"Blocking this user will not allow them to send you one to one messages anymore." buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Block", nil] hasInput:NO];
        [blockAlertView setDelegate:self];
        [blockAlertView show];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report Chat"]) {
        [_reportAlertView show];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Block"]) {
        [self handleBlockOneToOneChat];
    //Reporting
    } else if (alertView == _reportAlertView) {
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            if (_editingIndexPath.section == 0 && [_groupChats count] > _editingIndexPath.row) {
                [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createReportGroupChatPacket:_editingChat.chat_id type:[[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
            } else {
                [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createReportOneToOneChatPacket:_editingChat.chat_id type:[[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
            }
        }
    }
    
    [alertView close];
}

-(void)handleLeaveChat {
    if (_editingIndexPath.section == 0 && [_groupChats count] > _editingIndexPath.row) {
        [_groupChats removeObjectAtIndex:_editingIndexPath.row];
    } else if(_editingIndexPath.section == 1 && [_oneToOneChats count] > _editingIndexPath.row) {
        [_oneToOneChats removeObjectAtIndex:_editingIndexPath.row];
    } else if(_editingIndexPath.section == 2 && [_thoughtChats count] > _editingIndexPath.row) {
        [_thoughtChats removeObjectAtIndex:_editingIndexPath.row];
    } else {
        return;
    }
    [[self.cp getConnection] sendElement:[IQPacketManager createLeaveChatPacket:_editingChat.chat_id]];
    [MessagesDBManager deleteMessagesFromChatWithID:_editingChat.chat_id];
    [ChatDBManager deleteChat:_editingChat];
    [_tableView deleteRowsAtIndexPaths:@[_editingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    _editingChat = nil;
    _editingIndexPath = nil;
}

/*- (void)handleRenameChat:(UIAlertView *)alertView {
 NSString *name = [alertView textFieldAtIndex:0].text;
 [_editingChat setUser_defined_chat_name:name];
 [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
 [_tableView reloadData];
 
 }*/

- (void)handleRenameChat:(NSString *)newName {
    [_editingChat setUser_defined_chat_name:newName];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
    [_tableView reloadData];
    
}

- (void)showConfirmBlockDiaglog {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Blocking this user means they will no longer be able to create one to one chats with you." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil];
    [alertView show];
}

- (void)handleBlockOneToOneChat {
    NSString *otherUser = [_editingChat getMessageTo];
    [[self.cp getConnection] sendElement:[IQPacketManager createBlockImplicitUserPacket:otherUser]];
    [self.oneToOneChats removeObject:_editingChat];
    [ChatDBManager deleteChat:_editingChat];
    _editingChat = nil;
    [self.tableView reloadData];
}

@end
