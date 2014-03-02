//
//  MainSwipeViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/17/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MainSwipeViewController.h"
#import "DashboardViewController.h"
#import "FriendsViewController.h"
#import "ContactsViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"
#import "GroupChatManager.h"
#import "ChatParticipantVCardBuffer.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ConfessionsViewController.h"
#import "Constants.h"
#import "StyleManager.h"

#define NumViewPages 4

@interface MainSwipeViewController ()

@property UIPageViewController *pageViewController;
@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property (nonatomic, strong) GroupChatManager *groupChat;
@property (nonatomic, strong) ChatParticipantVCardBuffer *chatParticipant;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *friendRequests;
@property (nonatomic, strong) UITableView *notificationTableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *notificationButton;

@end

@implementation MainSwipeViewController

CAShapeLayer *openedNotifications;
CAShapeLayer *closedNotifications;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessagesRightArrowClicked) name:@"test" object:nil];
    
    [self.navigationController.navigationBar setHidden:YES];
    [self.navigationController setDelegate:self];
    
    // Initialize and configure page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Set the first controller to be shown
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    
    // Add the page view controller frame to the current view controller
    [_pageViewController.view setFrame:self.view.frame];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (IBAction)notificationsClicked:(id)sender {
    NSLog(@"Notifications Clicked");
    if(self.notificationTableView.hidden) {
        [self showNotifications];
    } else {
        [self hideNotifications];
    }
}

- (void)handleMessagesRightArrowClicked {
    __weak UIPageViewController *pvcw = _pageViewController;
    UIViewController *controller = [self viewControllerAtIndex:2];
    [_pageViewController setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        UIPageViewController *pvcs = pvcw;
        if (!pvcs) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [pvcs setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        });
    }];
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
                     }
                     completion:^(BOOL finished){
                         self.notificationTableView.hidden = YES;
                     }];
    [UIView commitAnimations];
}

- (IBAction)displayGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.view];
    
    if (!CGRectContainsPoint(self.notificationTableView.frame, tapLocation) && !self.notificationTableView.hidden) {
        [self hideNotifications];
    }
}

-(void)loadNotifications:(NSNotification *)notification {
    NSLog(@"Load notifications");
    
    self.groupChat = [GroupChatManager getInstance];
    self.notifications = self.groupChat.pending;
    self.chatParticipant = [ChatParticipantVCardBuffer getInstance];
    self.friendRequests = [[NSMutableArray alloc] initWithArray:[self.chatParticipant getPendingUserProfiles]];
    
    self.notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.05, 0, self.view.frame.size.width*0.9, self.view.frame.size.height*0.5)];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
    
    [self.view addSubview:self.notificationTableView];
    [self hideNotifications];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [self.notifications count];
    else
        return [self.friendRequests count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return NOTIFICATIONS_GROUP;
    else
        return NOTIFICATIONS_FRIEND;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
        cell.textLabel.text = [notification objectForKey:@"chatName"];
        [accept addTarget:self action:@selector(acceptInvitation:) forControlEvents:UIControlEventTouchUpInside];
        [decline addTarget:self action:@selector(declineInvitation:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friendRequest.firstName, friendRequest.lastName];
        NSLog(@"Friend: %@", [NSString stringWithFormat:@"%@ %@", friendRequest.firstName, friendRequest.lastName]);
        
        [accept addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [decline addTarget:self action:@selector(declineFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Accepted: %@", [notification objectForKey:@"chatId"]);
    
    [self.notifications removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Declined: %@", [notification objectForKey:@"chatId"]);
    
    [self.notifications removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)acceptFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send accept request packet
    
    NSLog(@"Accepted friend request");
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.notificationTableView];
    NSIndexPath *indexPath = [self.notificationTableView indexPathForRowAtPoint:click];
    
    UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send deny request packet
    
    NSLog(@"Declined friend request");
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.notificationTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (UIViewController*)viewControllerAtIndex:(int)index {
    NSString *storyboardID;
    
    if (index > NumViewPages || index < 0) {
        return nil;
    }
    
    switch (index) {
        case 0:
            storyboardID = STORYBOARD_ID_DASHBOARD_VIEW_CONTROLLER; break;
        case 1:
            storyboardID = STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER; break;
        case 2:
            storyboardID = STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER; break;
        case 3:
            storyboardID = STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER; break;
        default:
            return nil;
    }
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
    return viewController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:viewController] - 1;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int index = [self indexForViewController:viewController] + 1;
    return [self viewControllerAtIndex:index];
}

- (int)indexForViewController:(UIViewController*)viewController {
    int index = 0;
    if ([viewController isKindOfClass:[ConfessionsViewController class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[FriendsViewController class]]) {
        index = 2;
    } else if([viewController isKindOfClass:[ContactsViewController class]]) {
        index = 3;
    }
    return index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"Will Show view controller");
    if ([viewController isKindOfClass:[MainSwipeViewController class]]) {
        [self.navigationController.navigationBar setHidden:YES];
    } else {
        [self.navigationController.navigationBar setHidden:NO];
    }
    // -----------------
    // HACKY SOLUTION - Try to improve in the future
    // Updates confession posts after posting one
    // -----------------
    NSArray *childViewControllers = [[self pageViewController] childViewControllers];
    if ([childViewControllers count] > 2) {
        ConfessionsViewController *viewController;
        for (int i = 0; i < [childViewControllers count]; i++) {
            if ([[childViewControllers objectAtIndex:i] isKindOfClass:[ConfessionsViewController class]]) {
                viewController = [childViewControllers objectAtIndex:i];
                [viewController.tableView reloadData];
                i = (int)[childViewControllers count];
            }
        }
    }
}

@end
