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
#import "OneToOneChat.h"
#import "OneToOneChatManager.h"
#import "OneToOneConversationViewController.h"
#import "StyleManager.h"
@interface ConfessionsViewController ()

@property ConfessionsManager *confessionsManager;
@property (strong, nonatomic) NSMutableDictionary *cellCache;
@property (strong, nonatomic) UIImage *favIcon;
@property (strong, nonatomic) UIImage *favIconActive;
@property (strong, nonatomic) UIImage *gradLineSmall;
@property (strong, nonatomic) UIImage *chatIcon;
@property (strong, nonatomic) OneToOneChat *createdChat;

@end

@implementation ConfessionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.confessionsManager = [ConfessionsManager getInstance];
    
    UIImage *image = [UIImage imageNamed:@"grad-back-confessions.jpg"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setImage:image];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListView) name: PACKET_ID_GET_CONFESSIONS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOneToOneChatCreatedFromConfession) name:PACKET_ID_CREATE_ONE_TO_ONE_CHAT_FROM_CONFESSION object:nil];
    
    self.cellCache = [[NSMutableDictionary alloc] initWithCapacity:[_confessionsManager getNumberOfConfessions]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:backgroundImageView];
    [self.tableView setBackgroundColor:nil];
    [self.tableView setOpaque:YES];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.favIcon = [UIImage imageNamed:@"fav-icon.png"];
    self.favIconActive = [UIImage imageNamed:@"fav-icon-active.png"];
    self.gradLineSmall = [UIImage imageNamed:@"grad-line-small.png"];
    self.chatIcon = [UIImage imageNamed:@"chat-icon.png"];
    
    [self.bottomView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grad-bottom-confessions.jpg"]]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.confessionsManager getNumberOfConfessions];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicConfessionCell";
    Confession *confession = [_confessionsManager getConfessionAtIndex:(int)indexPath.row];
    if (self.cellCache == nil) {
        self.cellCache = [[NSMutableDictionary alloc] initWithCapacity:100];
    }   
    ConfessionTableCell *cell = [_cellCache objectForKey:[confession confessionID]];
    if (cell == nil) {
        cell = [[ConfessionTableCell alloc] initWithConfession:confession reuseIdentifier:CellIdentifier];
        if ([confession isFavoritedByConnectedUser]) {
            [cell.favoriteButton setImage:self.favIconActive forState:UIControlStateNormal];
        } else {
            [cell.favoriteButton setImage:self.favIcon forState:UIControlStateNormal];
        }
        [cell.chatButton setImage:self.chatIcon forState:UIControlStateNormal];
        [cell.gradLine setImage:self.gradLineSmall];
        [_cellCache setObject:cell forKey:[confession confessionID]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellText = [[[self confessionsManager] getConfessionAtIndex:(int)indexPath.row] body];
    UIFont *cellFont = [StyleManager getFontStyleNormal];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 60;
}

- (void)refreshListView {
    [self.tableView reloadData];
}

- (void)handleOneToOneChatCreatedFromConfession {
    _createdChat = [[OneToOneChatManager getInstance] getPendingChat];
    [self performSegueWithIdentifier:SEGUE_ID_CREATED_ONE_TO_ONE_CHAT_FROM_CONFESSION sender:self];
}

@end
