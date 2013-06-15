//
//  SPMClientViewController.h
//  SpeakerMesh
//
//  Created by Jonathan Graves on 6/15/13.
//  Copyright (c) 2013 HackDayTeamAwesome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SPMClientViewController : UIViewController <CLLocationManagerDelegate, UICollisionBehaviorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
- (IBAction)performPlayPause:(id)sender;

@end
