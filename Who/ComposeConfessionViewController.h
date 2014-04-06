//
//  ComposeConfessionViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 2/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController/Classes/JSBubbleView.h"

@interface ComposeConfessionViewController : UIViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
