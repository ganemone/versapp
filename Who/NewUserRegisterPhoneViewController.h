//
//  NewUserRegisterPhoneViewController.h
//  Versapp
//
//  Created by Giancarlo Anemone on 3/30/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPickerDelegate.h"

@interface NewUserRegisterPhoneViewController : CountryPickerDelegate<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phone;

-(NSString *)getSelectedCountryCode;
-(NSString *)getSelectedCountry;

@end
