//
//  WebViewController.m
//  Versapp
//
//  Created by Giancarlo Anemone on 7/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "WebViewController.h"
#import "Constants.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

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
    if ([_url isEqualToString:PRIVACY_URL]) {
        [_titleItem setTitle:@"Private Policy"];
    } else if ([_url isEqualToString:SUPPORT_URL]) {
        [_titleItem setTitle:@"Support"];
    } else if ([_url isEqualToString:TERMS_URL]) {
        [_titleItem setTitle:@"Terms"];
    } else {
        [_titleItem setTitle:@""];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
