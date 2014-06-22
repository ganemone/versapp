//
//  AddToGroupViewController.h
//  Versapp
//
//  Created by Riley Lundquist on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "FriendsViewController.h"

@protocol AddToGroupViewController

@property (strong, nonatomic) NSString *chatID;

-(void)setChatID:(NSString *)chatID;

@end

@interface AddToGroupViewController : FriendsViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, AddToGroupViewController>

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end
