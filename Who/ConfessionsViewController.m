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
#import "FriendsDBManager.h"
#import "WSCoachMarksView.h"
#import "ThoughtsCache.h"
#import "AppDelegate.h"

@interface ConfessionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *thoughtSegmentedControl;
@property ConfessionsManager *confessionsManager;
@property (strong, nonatomic) UIView *noFriendsView;
@property (strong, nonatomic) UIView *noPostsView;
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
@property BOOL isGlobalFeed;
@property BOOL isFetchingOlderThoughts;
@property BOOL didCreateChat;
@property BOOL didCreateChatInDB;
@property NSString *prevSince;
@property enum thoughtMethodTypes currentMethod;
@property (strong, nonatomic) CustomIOS7AlertView *reportAlertView;
@property (strong, nonatomic) Confession *actionConfession;

@end

@implementation ConfessionsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueIDTest"]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

- (IBAction)handleThoughtsTypeChanged:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    if ([control selectedSegmentIndex] == 0)
    {
        _currentMethod = THOUGHTS_METHOD_YOU;
        [self.view bringSubviewToFront:_tableView];
        [_noFriendsView removeFromSuperview];
    }
    else if ([control selectedSegmentIndex] == 1)
    {
        _currentMethod = THOUGHTS_METHOD_FRIENDS;
        if ([FriendsDBManager hasEnoughFriends] == NO)
        {
            [self.view addSubview:_noFriendsView];
            [self.view sendSubviewToBack:_noFriendsView];
            [self.view sendSubviewToBack:_tableView];
        }
    }
    else
    {
        [_noFriendsView removeFromSuperview];
        [self.view bringSubviewToFront:_tableView];
        _currentMethod = THOUGHTS_METHOD_GLOBAL;
    }
    
    [_confessionsManager setMethod:_currentMethod];
    
    if ([_confessionsManager hasCache]) {
        [self.tableView reloadData];
    }
    else {
        [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
        [_confessionsManager loadConfessions];
    }
}

-(void)doTutorial {
    Confession *confession = [_confessionsManager getConfessionAtIndex:0];
    NSString *CellIdentifier = [NSString stringWithFormat:@"ThoughtTableViewCell%@", confession.confessionID];
    ThoughtTableViewCell *firstCell = (ThoughtTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (firstCell == nil) {
        firstCell = [[[NSBundle mainBundle] loadNibNamed:@"ThoughtTableViewCell" owner:self options:nil] firstObject];
        [firstCell setUpWithConfession:confession];
    }
    CGRect favFrame = CGRectMake(firstCell.favBtn.frame.origin.x - 5, firstCell.favBtn.frame.origin.y - 5 + _header.frame.size.height, 55, 37);
    
    CGRect typeFrame = CGRectMake(firstCell.degreeBtn.frame.origin.x + 4, favFrame.origin.y, 40, 37);
    
    
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:_header.frame],//(CGRect){{0,0},{self.view.frame.size.width,44}}],
                                @"caption": @"You can view thoughts from around the globe, or just from your friends."
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width - 50, 20},{40,40}}],
                                @"caption": @"Click here to post a thought anonymously."
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:firstCell.frame],
                                @"caption": @"This is a thought posted anonymously by another person on Versapp.  If you are friends with them, you can start a conversation by clicking on the message icon."
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:favFrame],
                                @"caption": @"Click here to Favorite any thought anonymously"
                                },
                            @{
                                @"rect": [NSValue valueWithCGRect:typeFrame],
                                @"caption": @"You can see thoughts from friends, friends of friends, or global users. This icon tells you what type of thought you are looking at."
                                }
                            ];
    WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
    [self.view addSubview:coachMarksView];
    [coachMarksView start];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([UserDefaultManager hasSeenThoughts] == NO && [_tableView numberOfRowsInSection:0] > 0) {
        [UserDefaultManager setSeenThoughtsTrue];
        [self doTutorial];
    }
    
    [self refreshSegmentControl];
}

- (void)refreshSegmentControl {
    if (![FriendsDBManager hasEnoughFriends]) {
        _isGlobalFeed = YES;
        _currentMethod = THOUGHTS_METHOD_GLOBAL;
        [_thoughtSegmentedControl setSelectedSegmentIndex:2];
        [self loadConfessions];
        [self.tableView reloadData];
        [_noPostsView removeFromSuperview];
        [_noFriendsView removeFromSuperview];
    } else {
        _isGlobalFeed = NO;
        if ([_thoughtSegmentedControl selectedSegmentIndex] == 0) {
            _currentMethod = THOUGHTS_METHOD_YOU;
        } else if ([_thoughtSegmentedControl selectedSegmentIndex] == 1) {
            _currentMethod = THOUGHTS_METHOD_FRIENDS;
        } else {
            _currentMethod = THOUGHTS_METHOD_GLOBAL;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.confessionsManager = [ConfessionsManager getInstance];
    if ([self.confessionsManager getNumberOfConfessions] == 0) {
        [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
    }
    
    _didCreateChat = NO;
    _didCreateChatInDB = NO;
    
    [self refreshSegmentControl];
    
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    //[tableViewController setRefreshControl:refresh];
    [tableViewController setTableView:_tableView];
    //self.refreshControl = refresh;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    _tableBackgroundView = [[UIView alloc] init];
    [self.tableView setBackgroundView:_tableBackgroundView];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    lpgr.delegate = self;
    [_tableView addGestureRecognizer:lpgr];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _reportAlertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Bullying", @"Self Harm", @"Spam", @"Inappropriate", @"Cancel", nil]];
    [_reportAlertView setDelegate:self];
    
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
    
    _noFriendsView = [self getNoFriendsView];
    _noPostsView = [self getNoPostsView];
    
    _isFetchingOlderThoughts = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(refreshSegmentControl) name:PACKET_ID_GET_ROSTER object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name: PACKET_ID_GET_CONFESSIONS object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name:PACKET_ID_POST_CONFESSION object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name:NOTIFICATION_CONFESSION_DELETED object:nil];
    [defaultCenter addObserver:self selector:@selector(handleOneToOneChatCreationPacketReceived) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    [defaultCenter addObserver:self selector:@selector(handleOneToOneChatCreatedInLocalDB) name:NOTIFICATION_CREATED_THOUGHT_CHAT object:nil];
    if ([_confessionsManager getNumberOfConfessions] > 0) {
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:PACKET_ID_GET_ROSTER object:nil];
    [defaultCenter removeObserver:self name: PACKET_ID_GET_CONFESSIONS object:nil];
    [defaultCenter removeObserver:self name:PACKET_ID_POST_CONFESSION object:nil];
    [defaultCenter removeObserver:self name:NOTIFICATION_CONFESSION_DELETED object:nil];
    [defaultCenter removeObserver:self name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    [defaultCenter removeObserver:self name:NOTIFICATION_CREATED_THOUGHT_CHAT object:nil];
}

- (void)loadConfessions {
    [_confessionsManager setMethod:_currentMethod];
    [_confessionsManager loadConfessions];
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
    if (_currentMethod == THOUGHTS_METHOD_FRIENDS && [FriendsDBManager hasEnoughFriends] == NO) {
        return 0;
    }
    return [_confessionsManager getNumberOfConfessions];
}

- (UIView *)getNoFriendsView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIImage *image = [[UIImage alloc] init];
    if (screen.size.height < 500) {
        image = [UIImage imageNamed:@"sad-owl-small.png"];
    } else {
        image = [UIImage imageNamed:@"sad-owl-large.png"];
    }
    [imageView setImage:image];
    [backgroundView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _header.frame.size.height + 15, self.view.frame.size.width - 40, 50)];
    [titleLabel setFont:[StyleManager getFontStyleBoldSizeXL]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    NSUInteger numFriends = [[FriendsDBManager getAllWithStatusFriends] count];
    NSString *alert;
    if (numFriends == 0) {
        alert = @"You don't have any friends :(";
    } else if(numFriends == 1) {
        alert = @"You only have one friend.";
    } else {
        alert = @"You only have two friends.";
    }
    [titleLabel setText:alert];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 150, self.view.frame.size.width - 40, 150)];
    [textView setFont:[StyleManager getFontStyleLightSizeLarge]];
    [textView setText:@"To keep users' identities safe, you can only view the friends feed if you have at least 3 friends. For now, check out the global feed and share Versapp with your friends!"];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:[UIColor whiteColor]];
    [textView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundView addSubview:titleLabel];
    [backgroundView addSubview:textView];
    return backgroundView;
}

- (UIView *)getNoPostsView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGRect screen = [[UIScreen mainScreen] bounds];
    UIImage *image = [[UIImage alloc] init];
    if (screen.size.height < 500) {
        image = [UIImage imageNamed:@"sad-owl-small.png"];
    } else {
        image = [UIImage imageNamed:@"sad-owl-large.png"];
    }
    [imageView setImage:image];
    [backgroundView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _header.frame.size.height + 15, self.view.frame.size.width - 40, 50)];
    [titleLabel setFont:[StyleManager getFontStyleBoldSizeXL]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:@"Whoops - there is nothing here."];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 150, self.view.frame.size.width - 40, 150)];
    [textView setFont:[StyleManager getFontStyleLightSizeLarge]];
    [textView setText:@"Click the compose icon in the top right corner to share a thought anonymously. Or check out what your friends are posting!"];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:[UIColor whiteColor]];
    [textView setBackgroundColor:[UIColor clearColor]];
    
    [backgroundView addSubview:titleLabel];
    [backgroundView addSubview:textView];
    return backgroundView;
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
        
        if ([confession isPostedByConnectedUser]) {
            [cell.chatBtn addTarget:self action:@selector(handleConfessionDeleted:) forControlEvents:UIControlEventTouchUpInside];
            [cell.chatBtn setImage:[UIImage imageNamed:@"x-white.png"] forState:UIControlStateNormal];
            [cell.chatBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        } else {
            [cell.chatBtn setImage:[UIImage imageNamed:@"compose-white.png"] forState:UIControlStateNormal];
            [cell.chatBtn addTarget:self action:@selector(handleConfessionChatStarted:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
}

-(void)handleConfessionDeleted:(id)sender {
    //[[[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to delete this thought?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil] show];
    ThoughtTableViewCell *cell = (ThoughtTableViewCell *)[[[sender superview] superview] superview];
    _actionConfession = cell.confession;
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Delete Thought" message:@"Are you sure you want to delete this thought?" buttons:[NSMutableArray arrayWithObjects:@"Cancel", @"Delete", nil] hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

-(void)handleConfessionChatStarted:(id)sender {
    /*if ([FriendsDBManager hasEnoughFriends] && _confession.degree.length < 3) {
     [[[UIAlertView alloc] initWithTitle:@"" message:@"Would you like to start a chat with the poster of this thought?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
     } else {
     [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Messaging is restricted to friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
     }*/
    ThoughtTableViewCell *cell = (ThoughtTableViewCell *)[[[sender superview] superview] superview];
    _actionConfession = cell.confession;
    
    NSString *message;
    NSMutableArray *buttonTitles = [[NSMutableArray alloc] init];
    if ([FriendsDBManager hasEnoughFriends]) {
        message = @"Start a chat with the poster of this thought?";
        [buttonTitles addObjectsFromArray:[NSMutableArray arrayWithObjects:@"No", @"Yes", nil]];
    } else {
        message = @"Messaging is restricted to friends and friends of friends.";
        [buttonTitles addObjectsFromArray:[NSMutableArray arrayWithObject:@"Ok"]];
    }
    
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Conversation" message:message buttons:buttonTitles hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 320;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSDate *dateLastExecuted;
    NSDate *dateNow = [NSDate date];
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 80;
    CGFloat intervalSinceLastHitBottom = [dateNow timeIntervalSinceDate:dateLastExecuted];
    if(y > h - reload_distance && (isnan(intervalSinceLastHitBottom) || intervalSinceLastHitBottom > 3.0) && _isFetchingOlderThoughts == NO) {
        _isFetchingOlderThoughts = YES;
        [self loadOlderThoughts];
        dateLastExecuted = [NSDate date];
    }
}

- (void)loadOlderThoughts {
    [_confessionsManager setMethod:_currentMethod];
    [_confessionsManager loadConfessionsSince:[_confessionsManager getSinceForThoughtRequest]];
}

- (void)refreshListView
{
    [MBProgressHUD hideHUDForView:_tableView animated:YES];
    [_confessionsManager sortConfessions];
    [self.tableView reloadData];
    if (_isFetchingOlderThoughts == YES) {
        _isFetchingOlderThoughts = NO;
    } else {
        [self.tableView didFinishPullToRefresh];
    }
    
    if ([self.tableView numberOfRowsInSection:0] == 0) {
        if (_noPostsView.superview != self.view) {
            [self.view addSubview:_noPostsView];
            [self.view sendSubviewToBack:_noPostsView];
            [self.view sendSubviewToBack:_tableView];
        }
    } else {
        [_noPostsView removeFromSuperview];
    }
}

- (void)handleOneToOneChatCreationPacketReceived {
    _didCreateChat = YES;
    [self handleOneToOneChatCreatedFromConfession];
}

- (void)handleOneToOneChatCreatedInLocalDB {
    _didCreateChatInDB = YES;
    [self handleOneToOneChatCreatedFromConfession];
}

- (void)handleOneToOneChatCreatedFromConfession {
    _createdChat = [ChatDBManager getChatWithID:[ChatDBManager getChatIDPendingCreation]];
    if (_createdChat != nil && _didCreateChat == YES && _didCreateChatInDB == YES) {
        _didCreateChat = NO;
        _didCreateChatInDB = NO;
        [ChatDBManager resetChatIDPendingCreation];
        [self performSegueWithIdentifier:@"SegueIDTest" sender:self];
    }
}

- (IBAction)handleDiscloseInfoBtnClicked:(id)sender {
    NSString *info;
    if (_currentMethod == THOUGHTS_METHOD_FRIENDS)
    {
        info = @"This is your friends thoughts feed. These anonymous thoughts are from your friends and friends of friends. Both chatting and favoriting are also anonymous!";
    }
    else if(_currentMethod == THOUGHTS_METHOD_GLOBAL)
    {
        info = @"This is your global thoughts feed. These anonymous thoughts are from anyone other than your direct friends or friends of friends. You can't start a chat here, but you can anonymously favorite.";
    }
    else
    {
        info = @"This is a feed of your thoughts.";
    }
    CustomIOS7AlertView *alertView = [StyleManager createCustomAlertView:@"Thoughts" message:info buttons:[NSMutableArray arrayWithObject:@"Got it"] hasInput:NO];
    [alertView setDelegate:self];
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    NSLog(@"Reached Delegate");
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Report this Thought"]) {
        NSLog(@"Report this thought");
        [alertView close];
        [_reportAlertView show];
    } else if (alertView == _reportAlertView) {
        NSLog(@"Report alert view");
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createReportThoughtPacket:_actionConfession type:[[[alertView buttonTitleAtIndex:buttonIndex] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
            
        }
        [alertView close];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        NSLog(@"HERE");
        [alertView close];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_actionConfession startChat:^(ChatMO *chat) {
            NSLog(@"INSIDE BLOCK :%@", chat);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [[AppDelegate getCurrentViewController] performSegueWithIdentifier:SEGUE_ID_MAIN_TO_ONE_TO_ONE sender:chat];
        }];
    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete"]) {
        [alertView close];
        [_actionConfession deleteConfession];
    } else {
        [alertView close];
    }
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

- (void)loadImagesForThoughts {
    int numConfessions = [_confessionsManager getNumberOfConfessions];
    ImageCache *cache = [ImageCache getInstance];
    ImageManager *imageManager = [[ImageManager alloc] init];
    Confession *confession;
    for (int i = 0; i < numConfessions; i++) {
        confession = [_confessionsManager getConfessionAtIndex:i];
        if (![cache hasImageWithIdentifier:confession.confessionID] && ![[confession.imageURL substringToIndex:1] isEqualToString:@"#"]) {
            [imageManager downloadImageForThought:confession delegate:self];
        }
    }
}

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
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {}
-(void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url withError:(NSError *)error {
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];
    if (indexPath != nil && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self handleLongPressForRowAtIndexPath:indexPath];
    }
}

-(void)handleLongPressForRowAtIndexPath:(NSIndexPath*)indexPath {
    _actionConfession = [_confessionsManager getConfessionAtIndex:(int)indexPath.row];
    if (![_actionConfession isPostedByConnectedUser]) {
        CustomIOS7AlertView *alertView = [StyleManager createButtonOnlyAlertView:[NSArray arrayWithObjects:@"Report this Thought", @"Cancel", nil]];
        [alertView setDelegate:self];
        [alertView show];
    }
}

@end
