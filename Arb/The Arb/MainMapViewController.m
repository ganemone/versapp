//
//  MainMapViewController.m
//  The Arb
//
//  Created by Riley Lundquist on 6/25/14.
//  Copyright (c) 2014 Riley Lundquist. All rights reserved.
//

#import "MainMapViewController.h"

@interface MainMapViewController ()

@property (strong, nonatomic) GMSMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D arbCoordinates;

@end

@implementation MainMapViewController

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
    
    _arbCoordinates = CLLocationCoordinate2DMake(42.293469, -85.699842);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_arbCoordinates.latitude longitude:_arbCoordinates.longitude zoom:16];
    
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    [_mapView setMapType:kGMSTypeHybrid];
    self.view = _mapView;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    [marker setPosition:_arbCoordinates];
    [marker setTitle:@"The Arb"];
    [marker setSnippet:@"Lillian Anderson Arboretum"];
    //[marker setIcon:[UIImage imageNamed:@"tree-sample"]];
    [marker setMap:_mapView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
