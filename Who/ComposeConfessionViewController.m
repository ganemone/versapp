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
#import "PECropViewController.h"
#import "UserDefaultManager.h"
#import "GPUImage.h"
#import "ThoughtsDBManager.h"

@interface ComposeConfessionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *composeTextView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *effectLabel;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) NSString *backgroundColor;
@property (strong, nonatomic) NSString *backgroundImageLink;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) UIImage *e1;
@property (strong, nonatomic) UIImage *e2;
@property (strong, nonatomic) UIImage *e3;
@property (strong, nonatomic) UIImage *e4;
@property (strong, nonatomic) UIImage *e5;
@property CGFloat exposure;
@property int colorIndex;
@property int filterIndex;
@property int numFilters;
@property int shouldApplyFilter;

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

-(void)viewDidAppear:(BOOL)animated {
    if ([UserDefaultManager hasPostedThought] == NO) {
        [UserDefaultManager setPostedThoughtTrue];
        [[[UIAlertView alloc] initWithTitle:@"Thoughts" message:@"Post a thought to be seen anonymously by your friends. Swipe to change background colors, or add a picture and swipe to change filters and brightness" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles: nil] show];
    }
}

- (void)showHelperWithString:(NSString *)string
{
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progress setFrame:CGRectMake(progress.frame.origin.x, progress.frame.origin.y + 50, progress.frame.size.width, progress.frame.size.height)];
    [progress setMode:MBProgressHUDModeText];
    [progress setLabelText:string];
    [progress show:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [progress hide:YES];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.colorIndex = 0;
    self.filterIndex = 0;
    self.numFilters = 6;
    self.shouldApplyFilter = 0;
    self.exposure = -0.5;
    
    self.colors = @[[StyleManager getColorBlue], [StyleManager getColorGreen], [StyleManager getColorOrange], [StyleManager getColorPurple]];
    self.backgroundColor = [UIColor hexStringWithUIColor:[self.colors firstObject]];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp)];
    [upSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:upSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown)];
    [downSwipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:downSwipe];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    [self.headerLabel setFont:[StyleManager getFontStyleLightSizeHeader]];
    [self.composeTextView setFont:[StyleManager getFontStyleLightSizeThought]];
    [self.composeTextView setTextAlignment:NSTextAlignmentCenter];
    [self.composeTextView setDelegate:self];
    [self.composeTextView setText:@"Share a thought..."];
    [self.composeTextView setTextColor:[UIColor lightTextColor]];
    
    [_effectLabel setFont:[StyleManager getFontStyleLightSizeLarge]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedPostingConfession) name:PACKET_ID_POST_CONFESSION object:nil];
    [self adjustInsetsForTextfield:self.composeTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showHelperWithString:@"Swipe for colors"];
    });
}

#pragma mark - KeyboardNotifications

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize size = [[userInfo objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.25 animations:^{
        [_footerView setFrame:CGRectMake(0, self.view.frame.size.height - size.height - _footerView.frame.size.height, self.view.frame.size.height, _footerView.frame.size.height)];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        [_footerView setFrame:CGRectMake(0, self.view.frame.size.height - _footerView.frame.size.height, self.view.frame.size.height, _footerView.frame.size.height)];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postConfession:(id)sender {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    NSString *confessionText = [_composeTextView text];
    if (confessionText.length > 0) {
        if (_backgroundImage == nil) {
            Confession *confession = [Confession create:confessionText imageURL:_backgroundColor];
            [[ConfessionsManager getInstance] setPendingConfession:confession];
            [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createPostConfessionPacket:confession]];
        } else {
            [[[ImageManager alloc] init] uploadImageToGCS:_imageView.image delegate:self bucket:BUCKET_THOUGHTS];
        }
    } else {
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"You didn't write anything!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    [self handleFinishedPostingConfession];
}

- (IBAction)onBackPressed:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (IBAction)cameraBtnClicked:(id)sender {
    if (_backgroundImage == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Background Image" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo", @"Choose from library", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Background Image" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Take Photo", @"Choose from library", @"Remove Image", nil] show];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _backgroundImage = image;
    self.imageView.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (IBAction)openEditor
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = self.imageView.image;
    
    UIImage *image = self.imageView.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat x, y;
    CGFloat aspectRatio = 1;
    if (width/height > aspectRatio) {
        width = height * aspectRatio;
        x = (image.size.width - width)/2;
        y = 0;
    } else {
        height = width/aspectRatio;
        y = (image.size.height - height)/2;
        x = 0;
    }
    controller.imageCropRect = CGRectMake(x,
                                          y,
                                          width,
                                          height);
    controller.toolbarHidden = YES;
    controller.keepingCropAspectRatio = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:^{
        _exposure = -0.5;
        UIGraphicsBeginImageContext(CGSizeMake(320, 320));
        [croppedImage drawInRect:CGRectMake(0, 0, 320, 320)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        smallImage = [self getImageWithExposureApplied:smallImage];
        _backgroundImage = smallImage;
        [_imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_imageView setImage:smallImage];
        [_composeTextView setBackgroundColor:[UIColor clearColor]];
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self getFilteredImages];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [self showHelperWithString:@"Swipe for filters and brighness"];
        });
    }];
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void)getFilteredImages {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:_backgroundImage];
        GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
        [stillImageSource addTarget:sepiaFilter];
        [sepiaFilter useNextFrameForImageCapture];
        [stillImageSource processImage];
        _e1 = [sepiaFilter imageFromCurrentFramebuffer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Finished e1");
            if (_shouldApplyFilter == 1) {
                [self.imageView setImage:_e1];
                _shouldApplyFilter = 0;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self updateEffectLabelFilter];
            }
        });
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:_backgroundImage];
        GPUImageSoftEleganceFilter *filter = [[GPUImageSoftEleganceFilter alloc] init];
        [stillImageSource addTarget:filter];
        [filter useNextFrameForImageCapture];
        [stillImageSource processImage];
        _e5 = [filter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Finished e5");
            if (_shouldApplyFilter == 5) {
                [self.imageView setImage:_e5];
                _shouldApplyFilter = 0;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self updateEffectLabelFilter];
            }
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GPUImagePicture *stillImageSource1 = [[GPUImagePicture alloc] initWithImage:_backgroundImage];
        GPUImageMissEtikateFilter *filter1 = [[GPUImageMissEtikateFilter alloc] init];
        [stillImageSource1 addTarget:filter1];
        [filter1 useNextFrameForImageCapture];
        [stillImageSource1 processImage];
        _e2 = [filter1 imageFromCurrentFramebuffer];
        
        GPUImagePicture *stillImageSource2 = [[GPUImagePicture alloc] initWithImage:_backgroundImage];
        GPUImageAmatorkaFilter *filter2 = [[GPUImageAmatorkaFilter alloc] init];
        [stillImageSource2 addTarget:filter2];
        [filter2 useNextFrameForImageCapture];
        [stillImageSource2 processImage];
        _e3 = [filter2 imageFromCurrentFramebuffer];
        
        GPUImagePicture *stillImageSource3 = [[GPUImagePicture alloc] initWithImage:_backgroundImage];
        GPUImageSmoothToonFilter *filter3 = [[GPUImageSmoothToonFilter alloc] init];
        [stillImageSource3 addTarget:filter3];
        [filter3 useNextFrameForImageCapture];
        [stillImageSource3 processImage];
        _e4 = [filter3 imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Finished others");
            if (_shouldApplyFilter == 2) {
                [self.imageView setImage:_e2];
                _shouldApplyFilter = 0;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self updateEffectLabelFilter];
            } else if (_shouldApplyFilter == 3) {
                [self.imageView setImage:_e3];
                _shouldApplyFilter = 0;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self updateEffectLabelFilter];
            } else if (_shouldApplyFilter == 4) {
                [self.imageView setImage:_e4];
                _shouldApplyFilter = 0;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self updateEffectLabelFilter];
            }
        });
    });
}

- (void)updateImageWithCurrentExposure {
    UIImage *image = [self getImageWithExposureApplied:[self getCurrentImage]];
    [_imageView setImage:image];
}

- (UIImage *)getImageWithExposureApplied:(UIImage *)image {
    GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
    [filter setExposure:_exposure];
    [imageSource addTarget:filter];
    [filter useNextFrameForImageCapture];
    [imageSource processImage];
    return [filter imageFromCurrentFramebuffer];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        
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
            [self.view setBackgroundColor:[_colors objectAtIndex:_colorIndex]];
            _backgroundColor = [UIColor hexStringWithUIColor:_composeTextView.backgroundColor];
            _backgroundImage = nil;
            _backgroundImageLink = nil;
            _e1 = nil;
            _e2 = nil;
            _e3 = nil;
            _e4 = nil;
            _e5 = nil;
            return;
        } else if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Whoops" message:@"It looks like we need access to see your pictures." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
            return;
        }
        [_composeTextView resignFirstResponder];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:controller animated:YES completion:NULL];
}

-(void)handleFinishedPostingConfession {
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //[self.view setUserInteractionEnabled:YES];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - TextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if (newLength > 200) {
        [textView setFont:[StyleManager getFontStyleLightSizeXL]];
    } else {
        [textView setFont:[StyleManager getFontStyleLightSizeThought]];
    }
    return (newLength > 300) ? NO : YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    [self adjustInsetsForTextfield:textView];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Share a thought..."]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor];
    }
    [textView becomeFirstResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Share a thought...";
        textView.textColor = [UIColor lightTextColor];
    }
    [textView resignFirstResponder];
}

-(void)adjustInsetsForTextfield:(UITextView *)textView {
    UIFont *cellFont = [StyleManager getFontStyleLightSizeThought];
    CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT);
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [textView.text boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:ctx];
    CGFloat top = textView.frame.size.height/2 - textRect.size.height/2 - 10;
    CGFloat lowestPoint = _headerLabel.superview.frame.size.height + top + textRect.size.height;
    if (lowestPoint >= _footerView.frame.origin.y) {
        top = top - 20;
    }
    [textView setTextContainerInset:UIEdgeInsetsMake(top, 10, 0, 10)];
}

#pragma mark - ImageManagerDelegate

-(void)didFinishUploadingImage:(UIImage *)image toURL:(NSString *)url {
    Confession *confession = [Confession create:_composeTextView.text imageURL:url];
    [[ConfessionsManager getInstance] setPendingConfession:confession];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createPostConfessionPacket:confession]];
}

- (void)didFailToUploadImage:(UIImage *)image toURL:(NSString *)url withError:(NSError *)error {
    self.backgroundImage = nil;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Whoops" message:[NSString stringWithFormat:@"An error occurred when trying to upload your image.  Please check your network connection and try again. %@", error] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
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

#pragma mark - GestureManagement

- (void)handleDoubleTap {
    NSLog(@"View double tapped");
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_backgroundImage == nil) {
        [self handleSwipeWithColor:UISwipeGestureRecognizerDirectionRight];
    } else {
        [self handleSwipeWithImage:UISwipeGestureRecognizerDirectionRight];
    }
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (_backgroundImage == nil) {
        [self handleSwipeWithColor:UISwipeGestureRecognizerDirectionLeft];
    } else {
        [self handleSwipeWithImage:UISwipeGestureRecognizerDirectionLeft];
    }
}

- (void)handleSwipeWithColor:(UISwipeGestureRecognizerDirection)direction {
    if (direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Incrementing...");
        [self incrementColorIndex];
    } else {
        NSLog(@"Decrementing...");
        [self decrementColorIndex];
    }
    [_composeTextView setBackgroundColor:[_colors objectAtIndex:_colorIndex]];
    [self.view setBackgroundColor:[_colors objectAtIndex:_colorIndex]];
    _backgroundColor = [UIColor hexStringWithUIColor:_composeTextView.backgroundColor];
    [self updateEffectLabelColor];
}

- (void)handleSwipeWithImage:(UISwipeGestureRecognizerDirection)direction {
    if (direction == UISwipeGestureRecognizerDirectionRight) {
        [self incrementFilterIndex];
    } else {
        [self decrementFilterIndex];
    }
    if (_filterIndex == 0) {
        [_imageView setImage:_backgroundImage];
    } else if (_filterIndex == 1) {
        if (_e1 == nil) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _shouldApplyFilter = 1;
        } else {
            [self.imageView setImage:_e1];
        }
    } else if (_filterIndex == 2) {
        if (_e2 == nil) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _shouldApplyFilter = 2;
        } else {
            [self.imageView setImage:_e2];
        }
    } else if (_filterIndex == 3) {
        if (_e3 == nil) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _shouldApplyFilter = 3;
        } else {
            [self.imageView setImage:_e3];
        }
    } else if (_filterIndex == 4) {
        if (_e4 == nil) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _shouldApplyFilter = 4;
        } else {
            [self.imageView setImage:_e4];
        }
    } else if (_filterIndex == 5) {
        if (_e5 == nil) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _shouldApplyFilter = 5;
        } else {
            [self.imageView setImage:_e5];
        }
    }
    if (_shouldApplyFilter == 0) {
        [self updateEffectLabelFilter];
    }
}

- (void)incrementColorIndex {
    _colorIndex = (_colorIndex == [_colors count] - 1) ? 0 : _colorIndex + 1;
}

- (void)decrementColorIndex {
    _colorIndex = (_colorIndex == 0) ? [_colors count] - 1 : _colorIndex - 1;
}

- (void)incrementFilterIndex {
    _filterIndex = (_filterIndex == _numFilters - 1) ? 0 : _filterIndex + 1;
}

- (void)decrementFilterIndex {
    _filterIndex = (_filterIndex == 0) ? _numFilters - 1 : _filterIndex - 1;
}

- (void)decrementExposure {
    _exposure = MAX(-4, _exposure - 0.5);
    NSLog(@"Decrementing Exposure: %f", _exposure);
}

- (void)incrementExposure {
    _exposure = MIN(1, _exposure + 0.5);
    NSLog(@"Incrementing Exposure: %f", _exposure);
}

- (void)handleSwipeUp {
    if (_backgroundImage != nil) {
        [self incrementExposure];
        [self updateImageWithCurrentExposure];
    }
    
}

- (void)handleSwipeDown {
    if (_backgroundImage != nil) {
        [self decrementExposure];
        [self updateImageWithCurrentExposure];
    }
}

- (UIImage *)getCurrentImage {
    switch (_filterIndex) {
        case 0:return _backgroundImage;
        case 1:return _e1;
        case 2:return _e2;
        case 3:return _e3;
        case 4:return _e4;
        default: return _e5;
    }
}

#pragma mark - EffectLabelMethods

- (NSString *)getExposureString {
    if (_exposure >= 0) {
        if (_exposure == 0) {
            return @"Normal Brightness";
        } else {
            int percent = (int)_exposure*10;
            return [NSString stringWithFormat:@"%d%@ Brightened", percent, @"%"];
        }
    } else {
        int percent = abs((int)_exposure*10);
        return [NSString stringWithFormat:@"%d%@ Darkened", percent, @"%"];
    }
}

- (void)updateEffectLabelClear {
    [_effectLabel setText:@""];
}

- (void)updateEffectLabelExposure {
    [_effectLabel setText:[self getExposureString]];
}

- (void)updateEffectLabelFilter {
    [_effectLabel setText:[[[self class] filters] objectAtIndex:_filterIndex]];
}

- (void)updateEffectLabelBlur {
    
}

- (void)updateEffectLabelColor {
    [_effectLabel setText:[[[self class] colors] objectAtIndex:_colorIndex]];
}

+ (NSArray *)filters
{
    static NSArray *_titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _titles = @[@"No Filter",
                    @"Filter 1",
                    @"Filter 2",
                    @"Filter 3",
                    @"Filter 4",
                    @"Filter 5"];
    });
    return _titles;
}

+ (NSArray *)colors
{
    static NSArray *_colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _colors = @[@"Blue",
                    @"Green",
                    @"Orange",
                    @"Purple"];
    });
    return _colors;
}

#pragma mark - GestureRecognizerDelegate

@end
