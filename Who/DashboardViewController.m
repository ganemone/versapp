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
#import "MessagesDBManager.h"

@interface DashboardViewController()

@property (strong, nonatomic) ConnectionProvider* cp;
@property (strong, nonatomic) NSString *timeLastActive;
@property (strong, nonatomic) NSIndexPath *clickedCellIndexPath;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DashboardViewController

-(void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGetLastPacketReceived:) name:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshListView:) name:PACKET_ID_GET_VCARD object:nil];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [backgroundImageView setImage:[UIImage imageNamed:@"grad-back-messages.jpg"]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundView:backgroundImageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.cp = [ConnectionProvider getInstance];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier compare:SEGUE_ID_GROUP_CONVERSATION] == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        ConversationViewController *dest = segue.destinationViewController;
        dest.gc = [gcm getChatByIndex:self.clickedCellIndexPath.row];
    } else if([segue.identifier compare:SEGUE_ID_ONE_TO_ONE_CONVERSATION] == 0) {
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        OneToOneConversationViewController *dest = segue.destinationViewController;
        dest.chat = [cm getChatByIndex:self.clickedCellIndexPath.row];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 10.0f, self.view.frame.size.width, 30.0)];
    [customView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grad-back-messages.jpg"]]];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.frame = CGRectMake(10.0f, 10.0f, self.view.frame.size.width, 30.0);
    
    if (section == 0) {
        headerLabel.text = @"Groups";
    } else {
        headerLabel.text = @"One to One";
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChatCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
    
    if(indexPath.section == 0) {
        GroupChatManager *gcm = [GroupChatManager getInstance];
        GroupChat *muc = [gcm getChatByIndex:indexPath.row];
        cell.textLabel.text = muc.name;
        cell.detailTextLabel.text = [muc getLastMessageText];
    } else {
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        OneToOneChat *chat = [cm getChatByIndex:indexPath.row];
        cell.textLabel.text = chat.name;
        cell.detailTextLabel.text = [chat getLastMessageText];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.clickedCellIndexPath = indexPath;
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:SEGUE_ID_GROUP_CONVERSATION sender:self];
    } else {
        [self performSegueWithIdentifier:SEGUE_ID_ONE_TO_ONE_CONVERSATION sender:self];
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
    [self.tableView reloadData];
}

-(void)handleRefreshListView:(NSNotification*)notification {
    NSLog(@"Refreshing List View...");
    [self.tableView reloadData];
}

@end
