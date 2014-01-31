//
//  RequestsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "RequestsViewController.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "IQPacketManager.h"
#import "GroupChatManager.h"
#import "GroupChat.h"
#import "OneToOneChatManager.h"
#import "OneToOneChat.h"

@interface RequestsViewController ()

@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) NSMutableArray *groupNotifications, *oneToOneNotifications;

@end

@implementation RequestsViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPendingChatsPacket:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    self.connectionProvider = [ConnectionProvider getInstance];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createGetPendingChatsPacket]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Groups" : @"One To One";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.section == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        GroupChat *muc = [gcm getChatByIndex:indexPath.row];
        cell.textLabel.text = muc.name;
    } else {
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        OneToOneChat *chat = [cm getChatByIndex:indexPath.row];
        cell.textLabel.text = chat.name;
    }
    
    return cell;
}

-(void)handleGetPendingChatsPacket:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    NSString *type = [data objectForKey:@"chatType"];
    
    if ([type isEqualToString:CHAT_TYPE_GROUP]) {
        [self.groupNotifications addObject:[data objectForKey:@"chatName"]];
    } else {
        [self.oneToOneNotifications addObject:[data objectForKey:@"chatName"]];
    }
    
}

@end
