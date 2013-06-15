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
    UIDynamicAnimator *_animator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DefaultUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];

    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.statusLabel]];
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.statusLabel]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:gravityBehavior];
    [_animator addBehavior:collisionBehavior];
    
    collisionBehavior.collisionDelegate = self;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    _beaconRegion = nil;
    _locationManager = nil;
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    for(CLBeacon *beacon in beacons) {
        
    }
}

@end
