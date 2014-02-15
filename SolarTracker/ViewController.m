//
//  ViewController.m
//  SolarTracker
//
//  Created by Dave Sieh on 2/15/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    // Horizontal Controls
    IBOutlet UITextField *tfHorizontal;
    IBOutlet UIStepper *stpHorizontal;
    IBOutlet UISlider *sldHorizontal;

    // Vertical Controls
    IBOutlet UITextField *tfVertical;
    IBOutlet UIStepper *stpVertical;
    IBOutlet UISlider *sldVertical;

    // Light Sensor Controls
    
    IBOutlet UISwitch *swLightSensor;
    IBOutlet UITextField *tfLeftTop;
    IBOutlet UITextField *tfRightTop;
    IBOutlet UITextField *tfLeftBottom;
    IBOutlet UITextField *tfRightBottom;
    
    // BlueTooth Connect Controls
    IBOutlet UIButton *btnConnect;
    
    // States
    BOOL connected;

}
- (void)controlEnabling;
- (void)controlLabelling;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    connected = NO;
    
    [self controlEnabling];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Actions

- (IBAction)stpHorizontalChanged:(id)sender {
    float value = stpHorizontal.value;
    sldHorizontal.value = value;
    tfHorizontal.text = [NSString stringWithFormat:@"%d", (int)value];
}

- (IBAction)sldHorizontalChanged:(id)sender {
    float value = sldHorizontal.value;
    stpHorizontal.value = value;
    tfHorizontal.text = [NSString stringWithFormat:@"%d", (int)value];
}

- (IBAction)stpVerticalChanged:(id)sender {
    float value = stpVertical.value;
    sldVertical.value = value;
    tfVertical.text = [NSString stringWithFormat:@"%d", (int)value];
}

- (IBAction)sldVerticalChanged:(id)sender {
    float value = sldVertical.value;
    stpVertical.value = value;
    tfVertical.text = [NSString stringWithFormat:@"%d", (int)value];
}

- (IBAction)swLightSensorChanged:(id)sender {
    [self controlEnabling];
}

- (IBAction)btnConnectTouched:(id)sender {
    // For now, we are just going to toggle the connected
    // value.
    connected = !connected;
    
    [self controlLabelling];
    [self controlEnabling];
}

#pragma mark -
#pragma mark Private Methods

- (void)controlLabelling {
    if (connected) {
        [btnConnect setTitle:@"Disconnect"
                    forState:UIControlStateNormal];
    } else {
        [btnConnect setTitle:@"Connect"
                    forState:UIControlStateNormal];
    }
    
}

- (void)controlEnabling {
    BOOL lightSensorOn = swLightSensor.on;
    
    swLightSensor.enabled = connected;
    
    tfHorizontal.enabled = !lightSensorOn && connected;
    stpHorizontal.enabled = !lightSensorOn && connected;
    sldHorizontal.enabled = !lightSensorOn && connected;
    
    tfVertical.enabled = !lightSensorOn && connected;
    stpVertical.enabled = !lightSensorOn && connected;
    sldVertical.enabled = !lightSensorOn && connected;
    
    tfLeftBottom.enabled = lightSensorOn && connected;
    tfLeftTop.enabled = lightSensorOn && connected;
    tfRightBottom.enabled = lightSensorOn && connected;
    tfRightTop.enabled = lightSensorOn && connected;
}
@end
