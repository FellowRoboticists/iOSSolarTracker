//
//  GestureViewController.h
//  SolarTracker
//
//  Created by Dave Sieh on 2/22/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface GestureViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (atomic, strong) BLE *ble;

@end
