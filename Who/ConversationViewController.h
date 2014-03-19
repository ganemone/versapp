//
//  ConversationViewController.h
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
#import "ImageManager.h"
#import "ImageCache.h"
#import "ChatMO.h"

@interface ConversationViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource, ImageManagerDelegate>

@property (strong, nonatomic) ChatMO *chatMO;
@property (strong, nonatomic) ImageManager *im;
@property (strong, nonatomic) NSMutableArray *downloadingImageURLs;
@property (strong, nonatomic) ImageCache *imageCache;
@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *header;


@end
