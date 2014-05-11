//
//  ConfessionsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//
#import "UserDefaultManager.h"
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
#import "UIScrollView+GifPullToRefresh.h"
#import "ThoughtTableViewCell.h"
#import "MBProgressHUD.h"

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
@property (strong, nonatomic) UIView *tableBackgroundView;
@property CGFloat initialContentOffset;
@property CGFloat previousContentDelta;
@property BOOL isAnimatingHeader;

@end

@implementation ConfessionsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([UserDefaultManager hasSeenThoughts] == NO) {
        [UserDefaultManager setSeenThoughtsTrue];
        [self handleDiscloseInfoBtnClicked:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.confessionsManager = [ConfessionsManager getInstance];
    if ([self.confessionsManager getNumberOfConfessions] == 0) {
        //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name: PACKET_ID_GET_CONFESSIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name:PACKET_ID_POST_CONFESSION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name:NOTIFICATION_CONFESSION_DELETED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOneToOneChatCreatedFromConfession) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    //[tableViewController setRefreshControl:refresh];
    [tableViewController setTableView:_tableView];
    //self.refreshControl = refresh;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    _tableBackgroundView = [[UIView alloc] init];
    [self.tableView setBackgroundView:_tableBackgroundView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NSMutableArray *drawingImages = [NSMutableArray array];
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [drawingImages addObject:[UIImage imageNamed:fileName]];
    }
    
    for (int i = 0; i <= 15; i++) {
        NSString *fileName = [NSString stringWithFormat:@"Owl-Loading-Animation_0%03d.png",i];
        [loadingImages addObject:[UIImage imageNamed:fileName]];
    }
    [_tableView addPullToRefreshWithDrawingImgs:drawingImages andLoadingImgs:loadingImages andActionHandler:^{
        //Do your own work when refreshing, and don't forget to end the animation after work finished.
        [self performSelectorOnMainThread:@selector(loadConfessions) withObject:nil waitUntilDone:NO];
    }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_confessionsManager getNumberOfConfessions];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Confession *confession = [_confessionsManager getConfessionAtIndex:(int)indexPath.row];
    NSString *CellIdentifier = [NSString stringWithFormat:@"ThoughtTableViewCell%@", confession.confessionID];
    ThoughtTableViewCell *cell = (ThoughtTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ThoughtTableViewCell" owner:self options:nil] firstObject];
        [cell setUpWithConfession:confession];
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
    return 234;
}

- (void)refreshListView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_confessionsManager sortConfessions];
    [self loadImagesForThoughts];
    [self.tableView didFinishPullToRefresh];
    [self.tableView reloadData];
}

- (void)loadImagesForThoughts {
    int numConfessions = [_confessionsManager getNumberOfConfessions];
    ImageCache *cache = [ImageCache getInstance];
    ImageManager *imageManager = [[ImageManager alloc] init];
    Confession *confession;
    for (int i = 0; i < numConfessions; i++) {
        confession = [_confessionsManager getConfessionAtIndex:i];
        if (![cache hasImageWithIdentifier:confession.confessionID] && ![[confession.imageURL substringToIndex:1] isEqualToString:@"#"]) {
            NSLog(@"Downloading image...");
            [imageManager downloadImageForThought:confession delegate:self];
        }
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

/*- (IBAction)messageIconClicked:(id)sender {
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
}*/

- (IBAction)handleDiscloseInfoBtnClicked:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thoughts" message:@"This is your newsfeed of thoughts. Thoughts are anonymous and you only see the Thoughts of your friends. Both favoriting and chatting are also anonymous!" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
    [alertView show];
}

- (void)animateHideHeader {
    _isAnimatingHeader = YES;
    [UIView animateWithDuration:.5 animations:^{
        _header.center = CGPointMake(_header.center.x, -32);
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        _isAnimatingHeader = NO;
    }];
}

- (void)animateShowHeader {
    _isAnimatingHeader = YES;
    [UIView animateWithDuration:.5 animations:^{
        _header.center = CGPointMake(_header.center.x, 32);
        _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        _isAnimatingHeader = NO;
        _tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    }];
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 CGFloat delta = scrollView.contentOffset.y - self.initialContentOffset;
 if (scrollView.contentOffset.y < 0) {
 _header.center = CGPointMake(_header.center.x, 32);
 _tableView.frame = CGRectMake(0, 64, _tableView.frame.size.width, self.view.frame.size.height - 64);
 return;
 }
 CGFloat velocity = [[scrollView panGestureRecognizer] velocityInView:self.view].y;
 if (velocity > 300 && _isAnimatingHeader == NO) {
 [self animateShowHeader];
 } else if (velocity < - 300 && _isAnimatingHeader == NO) {
 [self animateHideHeader];
 }
 if (_isAnimatingHeader == NO) {
 if (delta > 0.f) {
 if (_header.center.y > -32) {
 _header.center = CGPointMake(_header.center.x, _header.center.y - delta);
 }
 if (_tableView.frame.origin.y > 0 || _tableView.frame.size.height < self.view.frame.size.height) {
 [_tableView setFrame:CGRectMake(0, MAX(0, abs(_tableView.frame.origin.y - delta)), _tableView.frame.size.width, MIN(self.view.frame.size.height, _tableView.frame.size.height + delta))];
 }
 } else if (delta < 0.f) {
 if (_header.center.y < 32) {
 _header.center = CGPointMake(_header.center.x, MIN(_header.center.y - delta, 32));
 }
 if (_tableView.frame.origin.y < 64 || _tableView.frame.size.height < (self.view.frame.size.height - 64)) {
 [_tableView setFrame:CGRectMake(0, MIN(64, _tableView.frame.origin.y - delta), _tableView.frame.size.width, MAX(self.view.frame.size.height - 64, _tableView.frame.size.height + delta))];
 }
 }
 }
 self.initialContentOffset = scrollView.contentOffset.y;
 self.previousContentDelta = delta;
 }
 
 - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
 self.initialContentOffset = scrollView.contentOffset.y;
 self.previousContentDelta = 0.f;
 }*/

#pragma ImageManagerDelegate

-(void)didFinishDownloadingImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    Confession *confession = [self.confessionsManager getConfessionWithID:identifier];
    NSUInteger index = [self.confessionsManager getIndexOfConfession:confession.confessionID];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)index inSection:0];
    if ([_tableView numberOfRowsInSection:0] > 0) {
        ThoughtTableViewCell *cell = (ThoughtTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell setUpBackgroundView];
    }
}

-(void)didFailToDownloadImageWithIdentifier:(NSString *)identifier {
    NSLog(@"Failed to download image...");
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {}
-(void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url {}


@end
