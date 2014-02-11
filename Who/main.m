//
//  main.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pixate/Pixate.h>
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        [Pixate licenseKey:@"J4N8R-E9NKI-GJKC4-CT8QE-K7ELB-EODE4-C1SAT-2NACA-B9LOI-IV8TT-SVRM8-J8LL5-JHNAP-DB4VM-37B43-3O" forUser:@"ganemone@gmail.com"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
