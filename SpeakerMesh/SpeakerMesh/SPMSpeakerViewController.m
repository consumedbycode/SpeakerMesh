//
//  SPMSpeakerViewController.m
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import "SPMSpeakerViewController.h"
#import "AFJSONRequestOperation.h"
#import "Constants.h"
#import "AFHTTPClient.h"

@interface SPMSpeakerViewController()

@end

@implementation SPMSpeakerViewController {

    AVAudioPlayer *_appSoundPlayer;
    CBPeripheralManager *_peripheralManager;
    NSTimer *_serverPollTimer;
    NSTimer *_serverUpdateTimer;
    NSNumber *_speakerId;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"04 - Johnny Cash - Folsom Prison Blues [Live]" ofType:@"mp3"];
    NSURL *soundFileUrl = [[NSURL alloc] initFileURLWithPath: soundFilePath];

    _appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error: nil];
    [_appSoundPlayer prepareToPlay];
    [_appSoundPlayer setVolume: 1.0];
    [_appSoundPlayer setDelegate: self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startBroadcasting];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self stopPlaying];
    _appSoundPlayer = nil;
    [self stopBroadcasting];
    _peripheralManager = nil;
    [_serverPollTimer invalidate];
    [_serverUpdateTimer invalidate];
}

- (void) startPlayingAtTime:(int)offset
{
    [_appSoundPlayer playAtTime:offset];
    self.playingStatusLabel.text = @"Playing at offset...";
    
    _serverUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(updateServer:)
                                                      userInfo:nil
                                                       repeats:YES];
}

- (void) stopPlaying
{
    [_appSoundPlayer stop];
    [_serverUpdateTimer invalidate];
    self.playingStatusLabel.text = @"Stopped.";
}

- (void) startBroadcasting
{
    if(_peripheralManager.state < CBPeripheralManagerStatePoweredOn)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bluetooth must be enabled" message:@"To configure your device as a beacon" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return;
    }

    NSURL *url = [NSURL URLWithString:@"http://curtisherbert.com/hack/getSpeakerId"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"Got speaker ID for server");
         [self broadcastWithId:(NSNumber *)JSON[@"newId"]];
     } failure:nil];
    [operation start];
}

- (void) broadcastWithId:(NSNumber *)serverAssignedId
{
    _speakerId = serverAssignedId;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:DefaultUUID];
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                     major:[_speakerId shortValue]
                                                                identifier:@"com.hackday.speakermesh"];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:@-59];
     
    if (peripheralData)
    {
        [_peripheralManager startAdvertising:peripheralData];
        self.broadcastingStatusLabel.text = @"Broadcasting...";
        
        
        _serverPollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector(pollServer:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
    else
    {
        self.broadcastingStatusLabel.text = @"Broadcast failed.";
    }
}

- (void) stopBroadcasting
{
    [_peripheralManager stopAdvertising];
    [_serverPollTimer invalidate];
    
    self.broadcastingStatusLabel.text = @"Broadcast stopped.";
    NSLog(@"Removing from server");
    
    NSURL *url = [NSURL URLWithString:@"http://curtisherbert.com/hack/removeSpeakerId"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"id", _speakerId,
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:params];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"Removed myself from the server");
     } failure:nil];
    [operation start];
}

- (void)updateServer:(NSTimeInterval)interval
{
    NSURL *url = [NSURL URLWithString:@"http://curtisherbert.com/hack/setCurrentPlayOffset"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"id", _speakerId,
                            @"offset", _appSoundPlayer.currentTime,
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:params];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSLog(@"Updated playback time on server");
     } failure:nil];
    [operation start];
}

- (void)pollServer:(NSTimeInterval)interval
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://curtisherbert.com/hack/getMeshStatus?beaconId%i", _speakerId.intValue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation =
        [AFJSONRequestOperation
             JSONRequestOperationWithRequest:request
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSLog(@"Got server status for spakers");
                 BOOL shouldPlay = (BOOL)JSON[@"shouldPlay"];
                 int offset = ((NSNumber *)JSON[@"offset"]).intValue;
                 int accuracy = ((NSNumber *)JSON[@"accuracy"]).doubleValue;
                 BOOL isPlaying = _appSoundPlayer.playing;
                 
                 if (shouldPlay && !isPlaying) {
                     [self startPlayingAtTime:offset];
                 } else if (!shouldPlay && isPlaying) {
                     [self stopPlaying];
                 }
                 
                 if (shouldPlay) {
                     //TODO deal with volume
                 }
                  
             } failure:nil];
    [operation start];    
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

@end
