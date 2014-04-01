//
//  TutorialSlideViewController.h
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialSlideViewController : UIViewController

@property int indexInTutorial;
@property (strong, nonatomic) UIImage *image;

- (id)initWithImage:(UIImage *)image indexInTutorial:(int)indexInTutorial;

@end
