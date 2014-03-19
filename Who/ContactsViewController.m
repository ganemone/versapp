//
//  ContactsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddressBook/AddressBook.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ContactSearchManager.h"
#import "FriendsDBManager.h"

@interface ContactsViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSArray *registeredContacts;
@property (strong, nonatomic) NSArray *unregisteredContacts;

@end

@implementation ContactsViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.registeredContacts = [FriendsDBManager getAllWithStatusRegistered];
    self.unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserSearchFinished) name:PACKET_ID_SEARCH_FOR_USERS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UPDATE_CONTACTS_VIEW object:nil];
    
    ContactSearchManager *csm = [ContactSearchManager getInstance];
    [csm accessContacts];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendMO *friend;
    if (indexPath.section == 0) {
        friend = [self.registeredContacts objectAtIndex:indexPath.row];
    } else {
        friend = [self.unregisteredContacts objectAtIndex:indexPath.row];
    }
    [cell.textLabel setText:friend.name];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [_registeredContacts count] : [_unregisteredContacts count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0) ? @"Versappers in your Contacts" : @"Invite to Versapp";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(void)handleUserSearchFinished {
    NSLog(@"Handling user search finished....");
    ContactSearchManager *csm = [ContactSearchManager getInstance];
    [csm updateContactListAfterUserSearch];
}

- (void)refreshData {
    _registeredContacts = [FriendsDBManager getAllWithStatusRegistered];
    _unregisteredContacts = [FriendsDBManager getAllWithStatusUnregistered];
    [self.tableView reloadData];
}

@end
