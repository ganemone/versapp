//
//  ComposeConfessionViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 2/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController/Classes/JSBubbleView.h"
#import "ImageManager.h"
#import "PECropViewController.h"

@interface ComposeConfessionViewController : UIViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageManagerDelegate, PECropViewControllerDelegate, UIGestureRecognizerDelegate>

@end
