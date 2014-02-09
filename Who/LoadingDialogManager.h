//
//  LoadingDialogManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/6/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingDialogManager : NSObject

+(LoadingDialogManager *)create:(UIView*)view;

-(void)showLoadingDialogWithoutProgress;

-(void)hideLoadingDialogWithoutProgress;

@end
