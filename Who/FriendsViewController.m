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
@end

@implementation FriendsViewController

-(void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetRosterPacketReceived:) name:PACKET_ID_GET_ROSTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:PACKET_ID_GET_VCARD object:nil];
    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetRosterPacket]];
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


@end
