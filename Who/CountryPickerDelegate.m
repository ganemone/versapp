//
//  CountryPickerDelegate.m
//  Versapp
//
//  Created by Giancarlo Anemone on 3/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "CountryPickerDelegate.h"
#import "UserDefaultManager.h"

@interface CountryPickerDelegate ()

@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSArray *countries;
@property (strong, nonatomic) UIPickerView *countryPicker;
@property (strong, nonatomic) UILabel *countryCodeField;

@end

@implementation CountryPickerDelegate

-(void)viewDidLoad {
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Countries" ofType:@"plist"];
    _countries = [NSArray arrayWithContentsOfFile:file];
}

-(void)setUp:(UIPickerView *)picker countryCodeField:(UILabel *)countryCodeField {
    [self setCountryPicker:picker];
    [self setCountryCodeField:countryCodeField];
    [self.countryPicker setDataSource:self];
    [self.countryPicker setDelegate:self];
    _countryCode = @"1";
    NSInteger row = 218;
    _country = [UserDefaultManager loadCountry];
    if ([_country length] != 0) {
        NSString *check = @"";
        for (NSDictionary *dict in _countries) {
            check = [dict objectForKey:@"country"];
            if ([check compare:_country] == 0) {
                row = [_countries indexOfObject:dict];
                _countryCode = [dict objectForKey:@"code"];
                break;
            }
        }
    }
    [self.countryCodeField setText:_countryCode];
    [self.countryPicker selectRow:row inComponent:0 animated:NO];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_countries count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[_countries objectAtIndex:row] objectForKey:@"country"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _countryCode = [[_countries objectAtIndex:row] objectForKey:@"code"];
    _country = [[_countries objectAtIndex:row] objectForKey:@"country"];
    [_countryCodeField setText:_countryCode];
}

@end