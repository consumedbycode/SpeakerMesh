//
//  SPMClientViewController.m
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import "SPMClientViewController.h"
#import "Constants.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface SPMClientViewController ()

@property (strong, nonatomic) NSArray *recentBeacons;

@end

@implementation SPMClientViewController {
    CLLocationManager *_locationManager;
    CLBeaconRegion *_beaconRegion;
    UIDynamicAnimator *_animator;
    BOOL _isPlaying;
    NSTimer *_serverUpdateTimer;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.statusLabel]];
    gravityBehavior.yComponent = 3;
    
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.statusLabel]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    
    [_animator addBehavior:gravityBehavior];
    [_animator addBehavior:collisionBehavior];
    
    collisionBehavior.collisionDelegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.recentBeacons = [[NSArray alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DefaultUUID];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    
    
    _serverUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateServer:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    [_serverUpdateTimer invalidate];
    _beaconRegion = nil;
    _locationManager = nil;
}

- (void) collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[self.statusLabel] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.yComponent = -.5;
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    self.recentBeacons = beacons;
}

- (void)updateServer:(NSTimeInterval)interval
{
    NSMutableArray *beaconsForServer = [[NSMutableArray alloc] init];
    
    for(CLBeacon *beacon in self.recentBeacons) {
        NSMutableDictionary *beaconForServer = [[NSMutableDictionary alloc] init];
        [beaconForServer setObject:@(beacon.accuracy) forKey:@"accuracy"];
        [beaconForServer setObject:@(beacon.proximity) forKey:@"proximity"];
        [beaconForServer setObject:beacon.major forKey:@"id"];
        
        [beaconsForServer addObject:beaconForServer];
    }
    
    NSURL *url = [NSURL URLWithString:@"http://curtisherbert.com/"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            beaconsForServer, @"knownSpeakers",
                            [NSNumber numberWithBool:_isPlaying], @"shouldBePlaying",
                            nil];
    [httpClient postPath:@"/hack/setCurrentStatus"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"Updated the server with beacons");
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                 }];
}

- (IBAction)performPlayPause:(id)sender
{
    _isPlaying = !_isPlaying;
}

@end
