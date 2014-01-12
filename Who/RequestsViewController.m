//
//  RequestsViewController.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "RequestsViewController.h"
#import "ConnectionProvider.h"

@interface RequestsViewController ()

@property(nonatomic, strong) ConnectionProvider *connectionProvider;

@end

@implementation RequestsViewController

- (IBAction)testConnection:(id)sender {
    self.connectionProvider = [[ConnectionProvider alloc]init];
    [self.connectionProvider connect:@"12695998050"];
}


@end
