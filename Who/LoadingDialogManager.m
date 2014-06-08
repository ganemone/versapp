//
//  LoadingDialogManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/6/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "LoadingDialogManager.h"

@interface LoadingDialogManager()

@property (strong, nonatomic) UIActivityIndicatorView *loadingDialogWithoutProgress;
@property (strong, nonatomic) UIView *view;
@property BOOL didInitLoadingDialog;

@end

@implementation LoadingDialogManager


+(LoadingDialogManager *)create:(UIView*)view {
    LoadingDialogManager *instance = [[LoadingDialogManager alloc] init];
    instance.loadingDialogWithoutProgress = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    instance.view = view;
    instance.didInitLoadingDialog = NO;
    return instance;
}

-(void)initLoadingDialog {
    self.loadingDialogWithoutProgress.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.loadingDialogWithoutProgress.center = self.view.center;
    [self.view addSubview:self.loadingDialogWithoutProgress];
    [self.loadingDialogWithoutProgress bringSubviewToFront:self.view];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    self.didInitLoadingDialog = YES;
}

-(void)showLoadingDialogWithoutProgress {
    if (self.didInitLoadingDialog == NO) {
        [self initLoadingDialog];
    }
    [self.loadingDialogWithoutProgress startAnimating];
}

-(void)hideLoadingDialogWithoutProgress {
    [self.loadingDialogWithoutProgress stopAnimating];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}

@end
