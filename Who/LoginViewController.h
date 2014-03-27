//
//  LoginViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/12/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPStream.h"

@interface LoginViewController : UIViewController <XMPPStreamDelegate, UITextFieldDelegate>

+(BOOL)validated;
+(void)setValidated:(BOOL)valid;

-(void)authenticated;

@end
