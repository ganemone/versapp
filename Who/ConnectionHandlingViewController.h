//
//  ConnectionHandlingViewController.h
//  Versapp
//
//  Created by Giancarlo Anemone on 3/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionHandlingViewController : UIViewController

@property BOOL shouldShowConnectionLostView;
@property BOOL viewHasAppeared;
@property BOOL connectionLostViewIsVisible;

- (void)showDisconnectedView;

@end
