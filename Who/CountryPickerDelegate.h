//
//  CountryPickerDelegate.h
//  Versapp
//
//  Created by Giancarlo Anemone on 3/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryPickerDelegate : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

-(void)setUp:(UIPickerView *)picker countryCodeField:(UILabel *)countryCodeField;

-(NSString *)getSelectedCountryCode;
-(NSString *)getSelectedCountry;

@end
