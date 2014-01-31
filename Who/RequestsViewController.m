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

@interface RequestsViewController ()

@property(nonatomic, strong) ConnectionProvider *connectionProvider;

@end

@implementation RequestsViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPendingChatsPacket:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    self.connectionProvider = [ConnectionProvider getInstance];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createGetPendingChatsPacket]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    return cell;
}

-(void)handleGetPendingChatsPacket:(NSNotification *)notification {
    NSDictionary *data = notification.userInfo;
    
}

@end
