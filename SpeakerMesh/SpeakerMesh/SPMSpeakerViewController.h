//
//  SPMSpeakerViewController.h
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface SPMSpeakerViewController : UIViewController <AVAudioPlayerDelegate, CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *playingStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *broadcastingStatusLabel;

@end
