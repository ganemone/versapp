//
//  ComposeConfessionViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 2/21/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ComposeConfessionViewController.h"
#import "Confession.h"
#import "ConfessionsManager.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "StyleManager.h"
#import "MBProgressHUD.h"
#import "ImageManager.h"
#import "UIColor+Hex.h"

@interface ComposeConfessionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) NSString *backgroundColor;
@property (strong, nonatomic) NSString *backgroundImageLink;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *filters;
@property int colorIndex;
@property int filterIndex;
@end

@implementation ComposeConfessionViewController

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
    self.colorIndex = 0;
    self.filterIndex = 0;
    self.colors = @[[StyleManager getColorBlue], [StyleManager getColorGreen], [StyleManager getColorOrange], [StyleManager getColorPurple]];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft |
                                   UISwipeGestureRecognizerDirectionRight)];
    [self.composeTextView addGestureRecognizer:swipeRecognizer];
    
    [self.headerLabel setFont:[StyleManager getFontStyleMediumSizeXL]];
    [self.composeTextView becomeFirstResponder];
    [self.composeTextView setFont:[StyleManager getFontStyleBoldSizeXL]];
    [self.composeTextView setTextAlignment:NSTextAlignmentCenter];
    [self.composeTextView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedPostingConfession) name:PACKET_ID_POST_CONFESSION object:nil];
    [self adjustInsetsForTextfield:self.composeTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postConfession:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    NSString *confessionText = [_composeTextView text];
    if (confessionText.length > 0) {
        NSString *imageURL = (_backgroundImageLink == nil) ? _backgroundColor : _backgroundImageLink;
        Confession *confession = [Confession create:confessionText imageURL:imageURL];
        [[ConfessionsManager getInstance] setPendingConfession:confession];
        [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createPostConfessionPacket:confession]];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You didn't write anything!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
}

- (IBAction)onBackPressed:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (IBAction)cameraBtnClicked:(id)sender {
    if (_backgroundImage == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Background Image" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo", @"Choose from library", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Background Image" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo", @"Choose from library", "Remove Image", nil] show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *prescaledImage = info[UIImagePickerControllerEditedImage];
    UIImage *image = [self imageWithImage:prescaledImage scaledToSize:_imageView.frame.size];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.backgroundImage = image;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[[ImageManager alloc] init] uploadImageToGCS:image delegate:self];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        
        if (buttonIndex == 1) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Your device doesn't support taking pictures." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                return;
            }
        } else if(buttonIndex == 3) {
            [_imageView setImage:nil];
            [_composeTextView setBackgroundColor:[_colors objectAtIndex:_colorIndex]];
            _backgroundColor = [UIColor hexStringWithUIColor:_composeTextView.backgroundColor];
            _backgroundImage = nil;
            _backgroundImageLink = nil;
        } else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"It looks like we need access to see your pictures." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            return;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)handleFinishedPostingConfession {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.view setUserInteractionEnabled:YES];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        return NO;
    }
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    [self adjustInsetsForTextfield:textView];
    if (newLength > 200) {
        [textView setFont:[StyleManager getFontStyleBoldSizeMed]];
    } else {
        [textView setFont:[StyleManager getFontStyleBoldSizeXL]];
    }
    return (newLength > 500) ? NO : YES;
}

-(void)adjustInsetsForTextfield:(UITextView *)textView {
    UIFont *cellFont = [StyleManager getFontStyleBoldSizeXL];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [textView.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    CGFloat top = textView.frame.size.height/2 - textRect.size.height;
    [textView setContentInset:UIEdgeInsetsMake(top, 10, 0, 10)];
}



#pragma mark - ImageManagerDelegate

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    _backgroundColor = nil;
    _backgroundImageLink = url;
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setImage:_backgroundImage];
    [_composeTextView setBackgroundColor:[UIColor clearColor]];
}

- (void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url {
    self.backgroundImage = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"An error occurred when trying to upload your image.  Please check your network connection and try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)didFinishDownloadingImage:(UIImage *)image withIdentifier:(NSString *)identifier {}
-(void)didFailToDownloadImageWithIdentifier:(NSString *)identifier {}

#pragma mark - ImageResizing

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    return [self imageWithImage:image scaledToSize:newSize];
}

#pragma mark - SwipeManagement

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_backgroundImage == nil) {
        [self handleSwipeWithColor:gestureRecognizer];
    } else {
        [self handleSwipeWithImage:gestureRecognizer];
    }
}

- (void)handleSwipeWithColor:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self incrementColorIndex];
    } else {
        [self decrementColorIndex];
    }
    [_composeTextView setBackgroundColor:[_colors objectAtIndex:_colorIndex]];
    _backgroundColor = [UIColor hexStringWithUIColor:_composeTextView.backgroundColor];
}

- (void)handleSwipeWithImage:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        [self incrementFilterIndex];
    } else {
        [self decrementColorIndex];
    }
    // Set filter here...
}

- (void)incrementColorIndex {
    _colorIndex = (_colorIndex == [_colors count] - 1) ? 0 : _colorIndex + 1;
}

- (void)decrementColorIndex {
    _colorIndex = (_colorIndex == 0) ? [_colors count] - 1 : _colorIndex - 1;
}

- (void)incrementFilterIndex {
    _filterIndex = (_filterIndex == [_filters count] - 1) ? 0 : _filterIndex + 1;
}

- (void)decrementFilterIndex {
    _filterIndex = (_filterIndex == 0) ? [_filters count] - 1 : _filterIndex - 1;
}

@end
