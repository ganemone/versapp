//
//  AddToGroupViewController.m
//  Versapp
//
//  Created by Riley Lundquist on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "AddToGroupViewController.h"
#import "ConnectionProvider.h"
#import "ChatMO.h"
#import "LoadingDialogManager.h"
#import "StyleManager.h"
#import "FriendsDBManager.h"
#import "Constants.h"
#import "FriendTableViewCell.h"
#import "ChatDBManager.h"

@interface AddToGroupViewController ()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSArray *allAccepted;
@property (strong, nonatomic) NSMutableArray *selectedJIDs;
@property (strong, nonatomic) NSArray *originalJIDs;
@property (strong, nonatomic) ChatMO *chatMO;
@property (strong, nonatomic) LoadingDialogManager *ldm;
@property (strong, nonatomic) NSString *invitedUser;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property BOOL isSearching;

@end

@implementation AddToGroupViewController

//@synthesize currentParticipants = _currentParticipants;
@synthesize chatID = _chatID;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[StyleManager getColorPurple]];
    [self.tableView setBackgroundColor:[StyleManager getColorPurple]];
    
    [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    [self.searchBar setDelegate:self];
    
    self.cp = [ConnectionProvider getInstance];
    self.ldm = [LoadingDialogManager create:self.view];
    self.allAccepted = [FriendsDBManager getAllWithStatusFriends];
    self.searchResults = _allAccepted;
    
    [self.header setFont:[StyleManager getFontStyleLightSizeHeader]];
    [self.bottomLabel setFont:[StyleManager getFontStyleLightSizeXL]];
}

- (IBAction)doneButtonClicked:(id)sender {
    [ChatDBManager setChatIDAddingParticipants:_chatMO.chat_id];
    [ChatDBManager addChatParticipants:_selectedJIDs];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setChatID:(NSString *)chatID {
    _chatID = chatID;
    _chatMO = [ChatDBManager getChatWithID:chatID];
    _selectedJIDs = [[NSMutableArray alloc] initWithArray:_chatMO.participants];
    _originalJIDs = [[NSArray alloc] initWithArray:_chatMO.participants];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\
    FriendMO *currentItem = [self.searchResults objectAtIndex:indexPath.row];
    FriendTableViewCell *cell = [[FriendTableViewCell alloc] initWithFriend:currentItem reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    if ([self.originalJIDs containsObject:currentItem.username]) {
        CGFloat btnSize = 18.0f;
        [cell.isSelectedImageView setFrame:CGRectMake(cell.frame.size.width - 50.0f, cell.frame.size.height / 2 - btnSize/2 + 2.0f, btnSize, 134.0f/(193.0f/btnSize))];
        [cell.isSelectedImageView setImage:[UIImage imageNamed:@"check-icon-purple.png"]];
    } else if ([self.selectedJIDs containsObject:currentItem.username]) {
        [cell.isSelectedImageView setImage:[UIImage imageNamed:@"cell-select-active.png"]];
    } else {
        [cell.isSelectedImageView setImage:[UIImage imageNamed:@"cell-select.png"]];
    }
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [super tableView:tableView viewForFooterInSection:section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = (FriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text compare:@"Loading..."] != 0) {
        NSString *jid;
        if ([self.searchResults count] > 0) {
            jid = [[self.searchResults objectAtIndex:indexPath.row] username];
        } else {
            jid = [[[self allAccepted] objectAtIndex:indexPath.row] username];
        }
        if([self.selectedJIDs containsObject:jid]) {
            if ([self.originalJIDs containsObject:jid]) {
                UIAlertView *noRemove = [[UIAlertView alloc] initWithTitle:@"What's the problem?" message: @"This page is for adding group members. You must use reporting to remove members from groups." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                
                noRemove.alertViewStyle = UIAlertViewStyleDefault;
                [noRemove show];
            } else {
                [self.selectedJIDs removeObject:jid];
                [cell setCellUnselected];
            }
        } else {
            [self.selectedJIDs addObject:jid];
            [cell setCellSelected];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self.tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

-(void)reloadData:(NSNotification*)notification {
    [self.tableView reloadData];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        self.isSearching = YES;
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        self.searchResults = [_allAccepted filteredArrayUsingPredicate:resultPredicate];
    } else {
        self.isSearching = NO;
        self.searchResults = _allAccepted;
    }
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = _allAccepted;
    [self.tableView reloadData];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
