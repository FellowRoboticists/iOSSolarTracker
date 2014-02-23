//
//  GestureViewController.m
//  SolarTracker
//
//  Created by Dave Sieh on 2/22/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//

#import "GestureViewController.h"
#import "AppSettings.h"

// Indexes into the picker control
#define SHAKE_YOUR_HEAD 0
#define NOD_YOUR_HEAD 1
#define DEJECTED_SHAKE 2

// Command values for BLE
#define DO_MAXIMUM_DELAY 2
#define DO_FOCUS 3
#define DO_MULTIPLIER 4
#define DO_SHAKE_YOUR_HEAD 5
#define DO_NOD_YOUR_HEAD 6
#define DO_DEJECTED_SHAKE 7

@interface GestureViewController () {
    
    IBOutlet UITextField *tfMaximumDelay;
    IBOutlet UITextField *tfFocus;
    IBOutlet UITextField *tfMultiplier;
    IBOutlet UIPickerView *pckGesture;
    IBOutlet UIStepper *stpMaximumDelay;
    IBOutlet UIStepper *stpFocus;
    IBOutlet UIStepper *stpMultiplier;
    
    NSArray *gestureNames;
}
- (IBAction)btnBack:(id)sender;
- (IBAction)btnMakeGesture:(id)sender;
- (IBAction)maximumDelayChanged:(id)sender;
- (IBAction)focusChanged:(id)sender;
- (IBAction)multiplierChanged:(id)sender;

- (IBAction)doneEditing:(id)sender;
@end

@implementation GestureViewController

@synthesize ble=_ble;

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
    tfFocus.text = [NSString stringWithFormat:@"%lu",(unsigned long)[AppSettings getFocus]];
    stpFocus.value = [AppSettings getFocus];
    tfMaximumDelay.text = [NSString stringWithFormat:@"%lu",(unsigned long)[AppSettings getMaximumDelay]];
    stpMaximumDelay.value = [AppSettings getMaximumDelay];
    tfMultiplier.text = [NSString stringWithFormat:@"%lu",(unsigned long)[AppSettings getMultiplier]];
    stpMultiplier.value = [AppSettings getMultiplier];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    gestureNames = @[@"Shake Your Head",
                     @"Nod Your Head",
                     @"Dejected Shake"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}


#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return gestureNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return gestureNames[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    // New Gesture selected. Nothing to do;
}

#pragma mark -
#pragma mark Actions

- (IBAction)btnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnMakeGesture:(id)sender {
    if (!_ble) return;

    int gestureCommand = DO_SHAKE_YOUR_HEAD;
    switch ([pckGesture selectedRowInComponent:0]) {
        case SHAKE_YOUR_HEAD:
            gestureCommand = DO_SHAKE_YOUR_HEAD;
            break;
            
        case NOD_YOUR_HEAD:
            gestureCommand = DO_NOD_YOUR_HEAD;
            break;
            
        case DEJECTED_SHAKE:
            gestureCommand = DO_DEJECTED_SHAKE;
            break;
            
        default:
            break;
    }

    // If the BLE is connected, go ahead and send the
    // following commands...
    if (_ble.isConnected) {
        // Set the values
        NSUInteger val = [tfFocus.text intValue];
        [self sendCommand:DO_FOCUS b1:val >> 8 b2:val];
        
        val = [tfMaximumDelay.text intValue];
        [self sendCommand:DO_MAXIMUM_DELAY b1:val >> 8 b2:val];

        val = [tfMultiplier.text intValue];
        [self sendCommand:DO_MULTIPLIER b1:val >> 8 b2:val];
        
        // Now, send the gesture
        [self sendCommand:gestureCommand b1:0x00 b2:0x00];
    }
}

- (IBAction)maximumDelayChanged:(id)sender {
    tfMaximumDelay.text = [NSString stringWithFormat:@"%d", (int)stpMaximumDelay.value];
    [AppSettings setMaximumDelay:(int)stpMaximumDelay.value];
}

- (IBAction)focusChanged:(id)sender {
    tfFocus.text = [NSString stringWithFormat:@"%d", (int)stpFocus.value];
    [AppSettings setFocus:(int)stpFocus.value];
}

- (IBAction)multiplierChanged:(id)sender {
    tfMultiplier.text = [NSString stringWithFormat:@"%d", (int)stpMultiplier.value];
    [AppSettings setMultiplier:stpMultiplier.value];
}

- (IBAction)doneEditing:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark -
#pragma mark BlueTooth Outbound Commands

- (void) sendCommand:(UInt8) cmd
                  b1:(UInt8) b1
                  b2:(UInt8) b2 {
    UInt8 buf[3];
    
    buf[0] = cmd;
    buf[1] = b1;
    buf[2] = b2;
    
    NSData *data = [NSData dataWithBytes:buf
                                  length:3];
    [_ble write:data];
}


@end
