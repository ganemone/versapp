//
//  FriendsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendsViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "UserProfile.h"
#import "ChatParticipantVCardBuffer.h"

@interface FriendsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *accepted;
@property (strong, nonatomic) NSArray *pending;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property BOOL isSelecting;

@end

@implementation FriendsViewController

-(void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetRosterPacketReceived:) name:PACKET_ID_GET_ROSTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    self.isSelecting = NO;
    self.selectedIndexPaths = [[NSMutableArray alloc] initWithCapacity:10];
    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetRosterPacket]];
}

- (IBAction)beginSelectingFriendsForGroup:(id)sender {
    if(self.navigationItem.leftBarButtonItem != nil) {
        NSLog(@"Creating Group...");
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
        self.navigationItem.leftBarButtonItem = nil;
        self.isSelecting = NO;
        if (self.selectedIndexPaths.count > 0) {
            UIAlertView *groupNamePrompt = [[UIAlertView alloc] initWithTitle:@"Group Name" message:@"Enter a name for the group" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
            groupNamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
            [groupNamePrompt show];
        }
        
    } else {
        NSLog(@"Changing Navigation Item....");
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelSelectingFriendsForGroup:)] animated:YES];
        self.isSelecting = YES;
    }
}

- (IBAction)cancelSelectingFriendsForGroup:(id)sender {
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(beginSelectingFriendsForGroup:)] animated:YES];
    self.navigationItem.leftBarButtonItem = nil;
    self.isSelecting = NO;
    for (int i = 0; i < self.selectedIndexPaths.count; i++) {
        [[self.tableView cellForRowAtIndexPath:[self.selectedIndexPaths objectAtIndex:i]] setAccessoryType:UITableViewCellAccessoryNone];
    }
    [self.selectedIndexPaths removeAllObjects];
}

-(void)handleGetRosterPacketReceived: (NSNotification*) notification{
    NSLog(@"Received Notification");
    NSDictionary *data = notification.userInfo;
    NSMutableArray *pending = [data objectForKey:USER_STATUS_PENDING];
    NSMutableArray *accepted =[data objectForKey:USER_STATUS_FRIENDS];
    self.accepted = accepted;
    self.pending = pending;
    NSLog(@"I got handleGet");
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID_FRIENDS_PROTOTYPE];
    }
    
    UserProfile *currentItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentItem = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        currentItem = [self.accepted objectAtIndex:indexPath.row];
    }
    
    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    if ([buff hasVCard:currentItem.jid] == YES) {
        currentItem.name = [buff getName:currentItem.jid];
        cell.textLabel.text = currentItem.name;
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelecting) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
            [self.selectedIndexPaths removeObject:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            [self.selectedIndexPaths addObject:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.accepted count];
    }
}

-(void)reloadData:(NSNotification*)notification {
    NSLog(@"Reloading Data...");
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResults = [self.accepted filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITableViewCell *cell;
    NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithCapacity:self.selectedIndexPaths.count];
    NSString *groupName = [alertView textFieldAtIndex:0].text;
    for (int i = 0; i < self.selectedIndexPaths.count; i++) {
        NSIndexPath *indexPath = [self.selectedIndexPaths objectAtIndex:i];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedItems addObject:[self.accepted objectAtIndex:indexPath.row]];
    }
    if (buttonIndex == 1 && groupName.length > 0) {
        //Create Group HERE
    }
}


@end
