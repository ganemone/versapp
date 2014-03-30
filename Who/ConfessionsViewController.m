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
@property (strong, nonatomic) NSMutableDictionary *cellCache;
@property (strong, nonatomic) UIImage *favIcon;
@property (strong, nonatomic) UIImage *favIconActive;
@property (strong, nonatomic) UIImage *gradLineSmall;
@property (strong, nonatomic) UIImage *chatIcon;
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
//    [self.refreshControl setAttributedTitle:attrString];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[StyleManager getColorOrange]];
    [self.tableView setBackgroundView:nil];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.favIcon = [UIImage imageNamed:@"fav-icon.png"];
    self.favIconActive = [UIImage imageNamed:@"fav-icon-active.png"];
    self.gradLineSmall = [UIImage imageNamed:@"grad-line-small.png"];
    self.chatIcon = [UIImage imageNamed:@"chat-icon.png"];
}

- (void)setUpInBackground {
    NSLog(@"Setting up In Background...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.confessionsManager = [ConfessionsManager getInstance];
        
        self.cellCache = [[NSMutableDictionary alloc] initWithCapacity:[_confessionsManager getNumberOfConfessions]];
        NSEnumerator *confessionEnumerator = [[_confessionsManager confessions] objectEnumerator];
        Confession *confession;
        
        while ((confession = [confessionEnumerator nextObject]) != nil) {
            NSLog(@"Setting up Confession...");
            [self.cellCache setObject:[self confessionTableCellForConfession:confession] forKey:confession.confessionID];
        }
    });
}

- (void)loadConfessions {
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createGetConfessionsPacket]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.cellCache = nil;
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
    if (self.cellCache == nil) {
        self.cellCache = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    ConfessionTableCell *cell = [_cellCache objectForKey:[confession confessionID]];
    if (cell == nil) {
        NSLog(@"Cell is nil...");
        cell = [[ConfessionTableCell alloc] initWithConfession:confession reuseIdentifier:CellIdentifier];
        if ([confession isFavoritedByConnectedUser]) {
            [cell.favoriteButton setImage:self.favIconActive forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:self.favIcon forState:UIControlStateNormal];
        }
        [cell.timestampLabel setText:[confession getTimePosted]];
        [cell.favoriteLabel setText:[confession getTextForLabel]];
        [cell.chatButton setImage:self.chatIcon forState:UIControlStateNormal];
        [_cellCache setObject:cell forKey:[confession confessionID]];
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
    [_cellCache removeAllObjects];
    
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



@end
