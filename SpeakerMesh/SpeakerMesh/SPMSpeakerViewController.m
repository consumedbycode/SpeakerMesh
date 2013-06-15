//
//  SPMSpeakerViewController.m
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import "SPMSpeakerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface SPMSpeakerViewController()

@end

@implementation SPMSpeakerViewController {

    AVAudioPlayer *_appSoundPlayer;
}

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

    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"04 - Johnny Cash - Folsom Prison Blues [Live]" ofType:@"mp3"];
    NSURL *soundFileUrl = [[NSURL alloc] initFileURLWithPath: soundFilePath];

    _appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileUrl error: nil];
    [_appSoundPlayer prepareToPlay];
    [_appSoundPlayer setVolume: 1.0];
    [_appSoundPlayer setDelegate: self];
    [_appSoundPlayer play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
