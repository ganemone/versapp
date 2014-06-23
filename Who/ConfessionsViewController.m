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

@interface ConfessionsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *thoughtSegmentedControl;
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
@property BOOL isGlobalFeed;
@property BOOL isFetchingOlderThoughts;
@property NSString *prevSince;
@property NSString *currentMethod;

@end

@implementation ConfessionsViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION]) {
        OneToOneConversationViewController *dest = segue.destinationViewController;
        [dest setChatMO:_createdChat];
    }
}

- (IBAction)handleThoughtsTypeChanged:(id)sender {
    UISegmentedControl *control = (UISegmentedControl *)sender;
    if ([control selectedSegmentIndex] == 0) {
        _currentMethod = @"friends";
    } else {
        _currentMethod = @"global";
    }
    [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
    [_confessionsManager loadConfessionsWithMethod:_currentMethod since:@"0"];
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
        _currentMethod = @"global";
        [_thoughtSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [_thoughtSegmentedControl setSelectedSegmentIndex:1];
    } else {
        _isGlobalFeed = NO;
        if (_currentMethod == nil)
            _currentMethod = @"friends";
        [_thoughtSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        _currentMethod = ([_thoughtSegmentedControl selectedSegmentIndex] == 1) ? @"global" : @"friends";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.confessionsManager = [ConfessionsManager getInstance];
    if ([self.confessionsManager getNumberOfConfessions] == 0) {
        [MBProgressHUD showHUDAddedTo:_tableView animated:YES];
    }
    
    [self refreshSegmentControl];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(refreshSegmentControl) name:PACKET_ID_GET_ROSTER object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name: PACKET_ID_GET_CONFESSIONS object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name:PACKET_ID_POST_CONFESSION object:nil];
    [defaultCenter addObserver:self selector:@selector(refreshListView) name:NOTIFICATION_CONFESSION_DELETED object:nil];
    [defaultCenter addObserver:self selector:@selector(handleOneToOneChatCreatedFromConfession) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    
    
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
    
    _isFetchingOlderThoughts = NO;
}

- (void)loadConfessions {
    [_confessionsManager loadConfessionsWithMethod:_currentMethod];
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
    
    if (indexPath.row == [_confessionsManager getNumberOfConfessions] - 2) {
        NSLog(@"Loading Older Thoughts...");
        if(_isFetchingOlderThoughts == NO) {
            NSString *since = [_confessionsManager getConfessionAtIndex:[_confessionsManager getNumberOfConfessions] - 1].createdTimestamp;
            if (![since isEqualToString:_prevSince]) {
                _prevSince = since;
                
                if ([_thoughtSegmentedControl selectedSegmentIndex] == 0) {
                    _currentMethod = @"friends";
                } else {
                    _currentMethod = @"global";
                }
                [_confessionsManager loadConfessionsWithMethod:_currentMethod since:since];
                _isFetchingOlderThoughts = YES;
            }
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 320;
}

- (void)refreshListView
{
    NSLog(@"Refreshing list view");
    [MBProgressHUD hideHUDForView:_tableView animated:YES];
    [_confessionsManager sortConfessions];
    //[self loadImagesForThoughts];
    [self.tableView didFinishPullToRefresh];
    [self.tableView reloadData];
    _isFetchingOlderThoughts = NO;
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
    NSString *info;
    if ([_currentMethod isEqualToString:@"friends"])
        info = @"This is your friends thoughts feed. These anonymous thoughts are from your friends and friends of friends. Both chatting and favoriting are also anonymous!";
    else
        info = @"This is your global thoughts feed. These anonymous thoughts are from anyone other than your direct friends or friends of friends. You can't start a chat here, but you can anonymously favorite.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thoughts" message:info delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil];
    
    /*CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0.8*self.view.frame.size.width, 40)];
    [header setFont:[StyleManager getFontStyleMediumSizeXL]];
    [header setTextAlignment:NSTextAlignmentCenter];
    [header setText:@"Thoughts"];
    [header setBackgroundColor:[UIColor clearColor]];
    
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0.8*self.view.frame.size.width, 10)];
    [content setFont:[StyleManager getFontStyleLightSizeLarge]];
    [content setTextAlignment:NSTextAlignmentCenter];
    [content setText:info];
    [content setBackgroundColor:[UIColor clearColor]];
    CGRect rect = [content.layoutManager usedRectForTextContainer:content.textContainer];
    [content setFrame:CGRectMake(0, header.frame.size.height, rect.size.width, rect.size.height+20)];
    //[content setScrollEnabled:NO];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, header.frame.size.width, header.frame.size.height+content.frame.size.height)];
    [container addSubview:header];
    [container addSubview:content];
    [container setBackgroundColor:[UIColor clearColor]];
    
    [alertView setContainerView:container];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Got it", nil]];
    [alertView setDelegate:self];*/
    
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if (buttonIndex == 0) {
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
            NSLog(@"Downloading image...");
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
    NSLog(@"Failed to download image...");
}

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {}
-(void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url withError:(NSError *)error {
    
}


@end
