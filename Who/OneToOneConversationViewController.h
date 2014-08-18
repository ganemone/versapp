//
//  OneToOneConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "ImageCache.h"
#import "ImageManager.h"
#import "ChatMO.h"
#import "CustomIOS7AlertView.h"
#import "ThoughtTableViewCell.h"

@interface OneToOneConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, ImageManagerDelegate, UIImagePickerControllerDelegate, CustomIOS7AlertViewDelegate>

@property (strong, nonatomic) ImageManager *im;
@property (strong, nonatomic) NSMutableArray *downloadingImageURLs;
@property (strong, nonatomic) ImageCache *imageCache;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) ChatMO *chatMO;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (strong, nonatomic) ThoughtTableViewCell *thoughtView;

@end
