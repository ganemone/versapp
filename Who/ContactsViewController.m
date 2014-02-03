//
//  ContactsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactsViewController.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "UserProfile.h"

@interface ContactsViewController()
@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *accepted;
@property (strong, nonatomic) NSArray *pending;
@end

@implementation ContactsViewController

-(void)viewDidLoad{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetRosterPacketReceived:) name:PACKET_ID_GET_ROSTER object:nil];
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
    UserProfile *currentItem = [self.accepted objectAtIndex:indexPath.row];
    cell.textLabel.text = currentItem.jid;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accepted count];
}


@end
