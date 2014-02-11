//
//  ConversationTableViewCell.m
//  Who
//
//  Created by Giancarlo Anemone on 2/10/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConversationTableViewCell.h"

@implementation ConversationTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)encoder
{
    self = [super initWithCoder:encoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
}

@end
