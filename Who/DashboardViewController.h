//
//  DashboardViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "CustomIOS7AlertView.h"

@interface DashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, CustomIOS7AlertViewDelegate>

@end
