//
//  DashboardViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "DashboardViewController.h"
#import "GroupChatManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface DashboardViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSString *timeLastActive;

@end

@implementation DashboardViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetLastPacketReceived:) name:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_UPDATE_DASHBOARD_LISTVIEW object:nil];

    self.cp = [ConnectionProvider getInstance];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetJoinedChatsPacket]];
    [[self.cp getConnection] sendElement:[IQPacketManager createGetLastTimeActivePacket]];
    
    [IQPacketManager createSendOneToOneMessagePacket:[Message create:@"body" sender:@"sender" chatID:@"chatID" timestamp:@"timestamp" messageTo:@"messageTo"]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChatCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    GroupChat *muc = [gcm getChatByIndex:indexPath.row];
    cell.textLabel.text = muc.name;
    cell.detailTextLabel.text = muc.history.getLastMessage;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GroupChatManager *gcm = [GroupChatManager getInstance];
    return [gcm getNumberOfChats];
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
}

-(void)handleRefreshListView:(NSNotification*)notification {
    NSLog(@"Refreshing List View");
    [self.tableView reloadData];
}

@end
