//
//  ConfessionsViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 2/19/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageManager.h"

@interface ConfessionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ImageManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) CAGradientLayer *gradient;
@end
