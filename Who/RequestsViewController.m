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
@property(nonatomic, strong) NSMutableArray *notifications;

@end

@implementation RequestsViewController

-(void)viewDidLoad {
    self.notifications =[[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPendingChatsPacket:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    self.connectionProvider = [ConnectionProvider getInstance];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createGetPendingChatsPacket]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    cell.textLabel.text = [notification objectForKey:@"chatName"];
    NSLog(@"Label: %@", [notification objectForKey:@"chatName"]);
    
    UIButton *accept = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    accept.frame = CGRectMake(175.0f, 5.0f, 50.0f, 30.0f);
    [accept setTitle:INVITATION_ACCEPT forState:UIControlStateNormal];
    [cell.contentView addSubview:accept];
    [accept addTarget:self action:@selector(acceptInvitation::) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decline = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    decline.frame = CGRectMake(250.0f, 5.0f, 50.0f, 30.0f);
    [decline setTitle:INVITATION_DECLINE forState:UIControlStateNormal];
    [cell.contentView addSubview:decline];
    [decline addTarget:self action:@selector(declineInvitation::) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    NSLog(@"Accepted: %ld", (long)indexPath.row);
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    NSLog(@"Declined: %ld", (long)indexPath.row);
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(void)handleGetPendingChatsPacket:(NSNotification *)notification {
    for (id note in notification.userInfo)
        [self.notifications addObject:[notification.userInfo objectForKey:note]];
    
    [self.tableView reloadData];
}

@end
