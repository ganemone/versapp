//
//  ThoughtViewController.h
//  Versapp
//
//  Created by Giancarlo Anemone on 9/8/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Confession.h"

@interface ThoughtViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) Confession *confession;

- (void)setUpWithConfession:(Confession *)confession;

@end
