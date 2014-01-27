//
//  DashboardViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardViewController.h"
#import "ConversationViewController.h"
#import "OneToOneConversationViewController.h"
#import "GroupChatManager.h"
#import "OneToOneChatManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface DashboardViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSString *timeLastActive;

@end

@implementation DashboardViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if([segue.identifier compare:SEGUE_ID_GROUP_CONVERSATION] == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        ConversationViewController *dest = segue.destinationViewController;
        NSLog(@"Got Destination Controller");
        dest.gc = [gcm getChatByIndex:indexPath.row];
        NSLog(@"Group Chat Info: %@ %d", dest.gc.name, [dest.gc getNumberOfMessages]);
        NSLog(@"Set Destination Controller Value");
    } else if([segue.identifier compare:SEGUE_ID_ONE_TO_ONE_CONVERSATION] == 0) {
        //OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        //OneToOneConversationViewController *dest = segue.destinationViewController;
    }
}

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetLastPacketReceived:) name:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_UPDATE_DASHBOARD_LISTVIEW object:nil];
    
    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetJoinedChatsPacket]];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetLastTimeActivePacket]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Groups" : @"One To One";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChatCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(indexPath.section == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        GroupChat *muc = [gcm getChatByIndex:indexPath.row];
        cell.textLabel.text = muc.name;
        cell.detailTextLabel.text = muc.history.getLastMessage;
    } else {
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        OneToOneChat *chat = [cm getChatByIndex:indexPath.row];
        cell.textLabel.text = chat.name;
        cell.detailTextLabel.text = chat.history.getLastMessage;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Section %d", indexPath.section);
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:SEGUE_ID_GROUP_CONVERSATION sender:self];
    } else {
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        return [gcm getNumberOfChats];
    } else {
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        return [cm getNumberOfChats];
    }
}

-(void)handleGetLastPacketReceived:(NSNotification*)notification {
    NSDictionary *data = notification.userInfo;
    NSString *utcTime = [data objectForKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    GroupChat *gc = nil;
    for (int i = 0; i < [gcm getNumberOfChats]; i++) {
        gc = [gcm getChatByIndex:i];
        [[self.cp getConnection] sendElement:[IQPacketManager createJoinMUCPacket:gc.chatID lastTimeActive:utcTime]];
    }
    [self.tableView reloadData];
}

-(void)handleRefreshListView:(NSNotification*)notification {
    NSLog(@"Refreshing List View");
    [self.tableView reloadData];
}

@end
