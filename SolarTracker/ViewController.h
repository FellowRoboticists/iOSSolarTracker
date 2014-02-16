//
//  ViewController.h
//  SolarTracker
//
//  Created by Dave Sieh on 2/15/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//
//  See LICENSE.txt for details.

#import <UIKit/UIKit.h>
#import "BLE.h"


@interface ViewController : UIViewController <BLEDelegate>


- (IBAction)stpHorizontalChanged:(id)sender;
- (IBAction)sldHorizontalChanged:(id)sender;


- (IBAction)stpVerticalChanged:(id)sender;
- (IBAction)sldVerticalChanged:(id)sender;


- (IBAction)swLightSensorChanged:(id)sender;


@end
