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
#import "ChatParticipantVCardBuffer.h"

@interface RequestsViewController ()

@property(nonatomic, strong) ConnectionProvider *connectionProvider;
@property(nonatomic, strong) ChatParticipantVCardBuffer *chatParticipant;
@property(nonatomic, strong) NSMutableArray *notifications;
@property(nonatomic, strong) NSMutableArray *friendRequests;

@end

@implementation RequestsViewController

-(void)viewDidLoad {
    self.notifications =[[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetPendingChatsPacket:) name:PACKET_ID_GET_PENDING_CHATS object:nil];
    
    self.connectionProvider = [ConnectionProvider getInstance];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createGetPendingChatsPacket]];
    
    self.chatParticipant = [ChatParticipantVCardBuffer getInstance];
    self.friendRequests = self.chatParticipant.pending;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return [self.notifications count];
    else
        return [self.friendRequests count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NotificationCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIButton *accept = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    accept.frame = CGRectMake(175.0f, 5.0f, 50.0f, 30.0f);
    [accept setTitle:INVITATION_ACCEPT forState:UIControlStateNormal];
    [cell.contentView addSubview:accept];
    
    UIButton *decline = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    decline.frame = CGRectMake(250.0f, 5.0f, 50.0f, 30.0f);
    [decline setTitle:INVITATION_DECLINE forState:UIControlStateNormal];
    [cell.contentView addSubview:decline];
    
    if (indexPath.section == 0) {
        NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
        cell.textLabel.text = [notification objectForKey:@"chatName"];
        NSLog(@"Notification: %@", [notification objectForKey:@"chatName"]);
        
        [accept addTarget:self action:@selector(acceptInvitation:) forControlEvents:UIControlEventTouchUpInside];
        [decline addTarget:self action:@selector(declineInvitation:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friendRequest.firstName, friendRequest.lastName];
        NSLog(@"Friend: %@", [NSString stringWithFormat:@"%@ %@", friendRequest.firstName, friendRequest.lastName]);
        
        [accept addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [decline addTarget:self action:@selector(declineFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (IBAction)acceptInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createAcceptChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Accepted: %@", [notification objectForKey:@"chatId"]);
    
    [self.notifications removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineInvitation:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    NSDictionary *notification = [self.notifications objectAtIndex:indexPath.row];
    [[self.connectionProvider getConnection] sendElement:[IQPacketManager createDenyChatInvitePacket:[notification objectForKey:@"chatId"]]];
    
    NSLog(@"Declined: %@", [notification objectForKey:@"chatId"]);
    
    [self.notifications removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)acceptFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send accept request packet
    
    NSLog(@"Accepted friend request");
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)declineFriendRequest:(id)sender {
    CGPoint click = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:click];
    
    UserProfile *friendRequest = [self.friendRequests objectAtIndex:indexPath.row];
    //Send deny request packet
    
    NSLog(@"Declined friend request");
    
    [self.friendRequests removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)handleGetPendingChatsPacket:(NSNotification *)notification {
    for (id note in notification.userInfo)
        [self.notifications addObject:[notification.userInfo objectForKey:note]];
    
    [self.tableView reloadData];
}

@end
