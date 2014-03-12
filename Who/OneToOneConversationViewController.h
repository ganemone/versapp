//
//  OneToOneConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/27/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneToOneChat.h"
#import "JSMessagesViewController.h"
#import "ImageCache.h"
#import "ImageManager.h"
#import "ChatMO.h"

@interface OneToOneConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, ImageManagerDelegate>

@property (strong, nonatomic) OneToOneChat *chat;
@property (strong, nonatomic) ImageManager *im;
@property (strong, nonatomic) NSMutableArray *downloadingImageURLs;
@property (strong, nonatomic) ImageCache *imageCache;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) ChatMO *chatMO;
@property (weak, nonatomic) IBOutlet UILabel *header;

@end
