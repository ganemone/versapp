//
//  LoginViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPStream.h"
#import <MessageUI/MessageUI.h>
#import "CustomIOS7AlertView.h"

@interface LoginViewController : UIViewController <XMPPStreamDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, CustomIOS7AlertViewDelegate>

-(void)authenticated;

@end
