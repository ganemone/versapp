//
//  ConfessionsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConfessionsViewController.h"
#import "Confession.h"
#import "ConfessionsManager.h"
#import "ConfessionTableCell.h"
#import "Constants.h"
#import "OneToOneConversationViewController.h"
#import "StyleManager.h"
#import "ChatDBManager.h"
#import "ChatMO.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface ConfessionsViewController ()

@property ConfessionsManager *confessionsManager;
@property (strong, nonatomic) UIImage *favIcon;
@property (strong, nonatomic) UIImage *favIconActive;
@property (strong, nonatomic) UIImage *favIconSingle;
@property (strong, nonatomic) UIImage *favIconSingleActive;
@property (strong, nonatomic) UIImage *gradLineSmall;
@property (strong, nonatomic) UIImage *chatIcon;
@property (strong, nonatomic) UIImage *deleteIcon;
@property (strong, nonatomic) ChatMO *createdChat;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ConfessionsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.confessionsManager = [ConfessionsManager getInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name: PACKET_ID_GET_CONFESSIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name:PACKET_ID_POST_CONFESSION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name:NOTIFICATION_CONFESSION_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOneToOneChatCreatedFromConfession) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    
    // Add a bottomBorder to the header view
    CALayer *headerBottomborder = [CALayer layer];
    headerBottomborder.frame = CGRectMake(0.0f, self.header.frame.size.height, self.header.frame.size.width, 2.0f);
    headerBottomborder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.header.layer addSublayer:headerBottomborder];
    // Add a top border to the footer view
    CALayer *footerTopBorder = [CALayer layer];
    footerTopBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 2.0f);
    footerTopBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.bottomView.layer addSublayer:footerTopBorder];
    
    [self.bottomTextField setDelegate:self];
    
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    //    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Pull to Refresh"];
    //    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrString.length)];
    [refresh addTarget:self action:@selector(refreshListView) forControlEvents:UIControlEventValueChanged];
    //    [refresh setAttributedTitle:attrString];
    
    [refresh setTintColor:[UIColor whiteColor]];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController setRefreshControl:refresh];
    [tableViewController setTableView:_tableView];
    self.refreshControl = refresh;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[StyleManager getColorOrange]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.favIcon = [UIImage imageNamed:@"fav-icon-label.png"];
    self.favIconActive = [UIImage imageNamed:@"fav-icon-label-active.png"];
    self.favIconSingle = [UIImage imageNamed:@"fav-icon-label-single.png"];
    self.favIconSingleActive = [UIImage imageNamed:@"fav-icon-label-single-active.png"];
    self.gradLineSmall = [UIImage imageNamed:@"grad-line-small.png"];
    self.chatIcon = [UIImage imageNamed:@"chat-icon-label.png"];
    self.deleteIcon = [UIImage imageNamed:@"delete-confession.png"];
}

- (void)loadConfessions {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createGetConfessionsPacket]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 10.0f)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_confessionsManager getNumberOfConfessions];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConfessionCellIdentifier";
    Confession *confession = [_confessionsManager getConfessionAtIndex:(int)indexPath.row];
    ConfessionTableCell *cell = [[ConfessionTableCell alloc] initWithConfession:confession reuseIdentifier:CellIdentifier];
    if ([confession isFavoritedByConnectedUser]) {
        if ([confession getNumForLabel] == 1) {
            [cell.favoriteButton setImage:self.favIconSingleActive forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:self.favIconActive forState:UIControlStateNormal];
        }
    } else {
        if ([confession getNumForLabel] == 1) {
            [cell.favoriteButton setImage:self.favIconSingle forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:self.favIcon forState:UIControlStateNormal];
        }
    }
    [cell.timestampLabel setText:[confession getTimePosted]];
    [cell.favoriteLabel setText:[confession getTextForLabel]];
    
    if ([confession isPostedByConnectedUser]) {
        [cell.chatButton removeFromSuperview];
        [cell.deleteButton setImage:self.deleteIcon forState:UIControlStateNormal];
    } else {
        [cell.deleteButton removeFromSuperview];
        [cell.chatButton setImage:self.chatIcon forState:UIControlStateNormal];
    }
    return cell;
}

- (ConfessionTableCell *)confessionTableCellForConfession:(Confession *)confession {
    static NSString *CellIdentifier = @"ConfessionCellIdentifier";
    ConfessionTableCell *cell = [[ConfessionTableCell alloc] initWithConfession:confession reuseIdentifier:CellIdentifier];
    if ([confession isFavoritedByConnectedUser]) {
        [cell.favoriteButton setImage:self.favIconActive forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setImage:self.favIcon forState:UIControlStateNormal];
    }
    [cell.timestampLabel setText:[confession getTimePosted]];
    [cell.favoriteLabel setText:[confession getTextForLabel]];
    [cell.chatButton setImage:self.chatIcon forState:UIControlStateNormal];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Confession *confession = [[self confessionsManager] getConfessionAtIndex:(int)indexPath.row];
    return [confession heightForConfession] - 8.0f;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Confession *confession = [[self confessionsManager] getConfessionAtIndex:(int)indexPath.row];
    return [confession heightForConfession] - 8.0f;
}

- (void)refreshListView
{
    [_confessionsManager sortConfessions];
    if ([self.refreshControl isRefreshing]) {
        
        NSMutableAttributedString *refreshTitle = [[NSMutableAttributedString alloc]initWithString:@"Refreshing..."];
        [refreshTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, refreshTitle.length)];
        [self.refreshControl setAttributedTitle:refreshTitle];
        [self loadConfessions];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
    else {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"Pull to refresh"];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attrString.length)];
        [self.refreshControl setAttributedTitle:attrString];
    }
    [self.tableView reloadData];
}

- (void)handleOneToOneChatCreatedFromConfession {
    _createdChat = [ChatDBManager getChatWithID:[ChatDBManager getChatIDPendingCreation]];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION sender:self];
    [ChatDBManager resetChatIDPendingCreation];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self performSegueWithIdentifier:SEGUE_ID_COMPOSE_CONFESSION sender:self];
    return NO;
}

- (IBAction)messageIconClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionReverse], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_MESSAGES
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)friendIconClicked:(id)sender {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:UIPageViewControllerNavigationDirectionForward], @"direction", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_NAVIGATE_TO_FRIENDS
                                                        object:nil
                                                      userInfo:userInfo];
}

- (IBAction)handleDiscloseInfoBtnClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confessions" message:@"This is your newsfeed of confessions. Confessions are anonymous and you only see the confessions of your friends. Try favoriting a confession, or starting a chat with a confession poster! They are both done completely anonymously!" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
    [alertView show];
}


@end
