//
//  SPMClientViewController.m
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import "SPMClientViewController.h"
#import "Constants.h"

@interface SPMClientViewController ()

@end

@implementation SPMClientViewController {
    CLLocationManager *_locationManager;
    CLBeaconRegion *_beaconRegion;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    self.locatedSpeakersTableView.delegate = self;

    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:DefaultUUID identifier:[DefaultUUID UUIDString]];
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    _beaconRegion = nil;
    _locationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"found beacons" message:[NSString stringWithFormat:@"%i beacon(s) found.", beacons.count] delegate:self cancelButtonTitle:@"Sah-weet!" otherButtonTitles:nil];
    [errorAlert show];
    return;

}

@end
