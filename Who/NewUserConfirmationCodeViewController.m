//
//  NewUserConfirmationCodeViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 4/1/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "NewUserConfirmationCodeViewController.h"

@interface NewUserConfirmationCodeViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *confirmationPicker;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@end

@implementation NewUserConfirmationCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", (long)row];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (IBAction)actionBtnClicked:(id)sender {
    NSString *firstDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:0] forComponent:0];
    NSString *secondDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:1] forComponent:1];
    NSString *thirdDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:2] forComponent:2];
    NSString *fourthDigit = [self pickerView:_confirmationPicker titleForRow:[_confirmationPicker selectedRowInComponent:3] forComponent:3];
    NSString *code = [NSString stringWithFormat:@"%@%@%@%@", firstDigit, secondDigit, thirdDigit, fourthDigit];
    NSLog(@"Code: %@", code);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
