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
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_ID_PAGE_VIEW_CONTROLLER];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[initialViewController];

    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [_pageViewController.view setFrame:self.view.frame];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNotifications:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    self.connectionProvider = [ConnectionProvider getInstance];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createGetPendingChatsPacket]];
    
    [self drawOpenLayer];
    [self drawClosedLayer];
}

- (IBAction)notificationsClicked:(id)sender {
    NSLog(@"Notifications Clicked");
    if(self.notificationTableView.hidden) {
        [self showNotifications];
    } else {
        [self hideNotifications];
    }
}

- (void) showNotifications {
    NSLog(@"Show Notifications");
    
    [self.view addSubview:self.notificationTableView];
    
    self.notificationTableView.hidden = NO;
    
    /*[closedNotifications removeFromSuperlayer];
    [[[self view] layer] addSublayer:openedNotifications];
    
    // Set new origin of menu
    CGRect notificationFrame = self.notificationTableView.frame;
    notificationFrame.origin.y = self.view.frame.size.height;
    
    // Set new alpha of Container View (to get fade effect)
    //float containerAlpha = 0.5f;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.notificationTableView.frame = notificationFrame;
                         //[self.container setAlpha: containerAlpha];
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];*/
    
}

- (void) hideNotifications {
    NSLog(@"Hide Notifications");
    
    [self.notificationTableView removeFromSuperview];
    
    self.notificationTableView.hidden = YES;
    
    /*// Set the border layer to hidden menu state
    [openedNotifications removeFromSuperlayer];
    [[[self view] layer] addSublayer:closedNotifications];
    
    // Set new origin of menu
    CGRect notificationFrame = self.notificationTableView.frame;
    notificationFrame.origin.y = self.view.frame.size.height-notificationFrame.size.height;
    
    // Set new alpha of Container View (to get fade effect)
    //float containerAlpha = 1.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.05f
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.notificationTableView.frame = notificationFrame;
                         //[self.container setAlpha: containerAlpha];
                     }
                     completion:^(BOOL finished){
                         self.notificationTableView.hidden = YES;
                     }];
    [UIView commitAnimations];*/
    
}

- (void) drawOpenLayer {
    openedNotifications = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    int triangleSize = 8;
    int trianglePosition = 0.87*width;
    
    // The path for the triangle (showing that the menu is open).
    UIBezierPath *triangleShape = [[UIBezierPath alloc] init];
    [triangleShape moveToPoint:CGPointMake(trianglePosition, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+triangleSize, height-triangleSize)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition, height)];
    
    [openedNotifications setPath:triangleShape.CGPath];
    //[openMenuShape setFillColor:[self.menubar.backgroundColor CGColor]];
    [openedNotifications setFillColor:[self.notificationTableView.backgroundColor CGColor]];
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+triangleSize, height-triangleSize)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [openedNotifications setPath:borderPath.CGPath];
    [openedNotifications setStrokeColor:[[UIColor whiteColor] CGColor]];
    
    [openedNotifications setBounds:CGRectMake(0.0f, 0.0f, height+triangleSize, width)];
    [openedNotifications setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [openedNotifications setPosition:CGPointMake(0.0f, 0.0f)];
}

- (void) drawClosedLayer {
    closedNotifications = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.view.frame.size.height;
    int width = self.view.frame.size.width;
    
    // The path for the border (just a straight line)
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [closedNotifications setPath:borderPath.CGPath];
    [closedNotifications setStrokeColor:[[UIColor whiteColor] CGColor]];
    
    [closedNotifications setBounds:CGRectMake(0.0f, 0.0f, height, width)];
    [closedNotifications setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [closedNotifications setPosition:CGPointMake(0.0f, 0.0f)];
}

-(void)loadNotifications:(NSNotification *)notification {
    NSLog(@"Load notifications");
    
    self.groupChat = [GroupChatManager getInstance];
    self.notifications = self.groupChat.pending;
    NSLog(@"%d notifications", [self.notifications count]);
    self.chatParticipant = [ChatParticipantVCardBuffer getInstance];
    self.friendRequests = self.chatParticipant.pending;
    NSLog(@"%d friend requests", [self.friendRequests count]);
    
    self.notificationTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, 0, self.view.frame.size.width*0.8, self.view.frame.size.height*0.3)];
    self.notificationTableView.hidden = YES;
    [self.notificationTableView setDelegate:self];
    [self.notificationTableView setDataSource:self];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSLog(@"created cell when null");
    }
    
    UIButton *accept = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    accept.frame = CGRectMake(175.0f, 5.0f, 50.0f, 30.0f);
    [accept setTitle:INVITATION_ACCEPT forState:UIControlStateNormal];
    [cell.contentView addSubview:accept];
    
    UIButton *decline = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    decline.frame = CGRectMake(250.0f, 5.0f, 50.0f, 30.0f);
    [decline setTitle:INVITATION_DECLINE forState:UIControlStateNormal];
    [cell.contentView addSubview:decline];
    
    NSLog(@"Cell: %@", [cell description]);
    if (indexPath.section == 0) {
        NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
        cell.textLabel.text = [notification objectForKey:@"chatName"];
        //[[cell textLabel] setText:[notification objectForKey:@"chatName"]];
        NSLog(@"Notification: %@", [notification objectForKey:@"chatName"]);
        
        NSLog(@"Testing cell...%@", cell.textLabel.text);
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


-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[ConversationViewController class]] ||
        [viewController isKindOfClass:[OneToOneConversationViewController class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
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
            storyboardID = STORYBOARD_ID_FRIENDS_VIEW_CONTROLLER; break;
        case 2:
            storyboardID = STORYBOARD_ID_CONTACTS_VIEW_CONTROLLER; break;
        case 3:
            storyboardID = STORYBOARD_ID_CONFESSIONS_VIEW_CONTROLLER; break;
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
    if ([viewController isKindOfClass:[FriendsViewController class]]) {
        index = 1;
    } else if([viewController isKindOfClass:[ContactsViewController class]]) {
        index = 2;
    } else if([viewController isKindOfClass:[ConfessionsViewController class]]) {
        index = 3;
    }
    return index;
}

/*-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return NumViewPages;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
