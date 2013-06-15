//
//  SPMSpeakerViewController.m
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import "SPMSpeakerViewController.h"

@interface SPMSpeakerViewController()

@end

@implementation SPMSpeakerViewController {

    AVAudioPlayer *_appSoundPlayer;
    CBPeripheralManager *_peripheralManager;
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

    [self startPlaying];
    [self startBroadcasting];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [self stopPlaying];
    _appSoundPlayer = nil;
    [self stopBroadcasting];
    _peripheralManager = nil;

}

- (void) startPlaying
{
    [_appSoundPlayer play];
    self.playingStatusLabel.text = @"Playing...";
}

- (void) stopPlaying
{
    [_appSoundPlayer stop];
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

    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"com.hackday.speakermesh"];
    NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:@-59];
    if (peripheralData)
    {
        [_peripheralManager startAdvertising:peripheralData];
        self.broadcastingStatusLabel.text = @"Broadcasting...";
    }
    else
    {
        self.broadcastingStatusLabel.text = @"Broadcast failed.";
    }
}

- (void) stopBroadcasting
{
    [_peripheralManager stopAdvertising];
    self.broadcastingStatusLabel.text = @"Broadcast stopped.";
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

@end
