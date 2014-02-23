//
//  ViewController.m
//  SolarTracker
//
//  Created by Dave Sieh on 2/15/14.
//  Copyright (c) 2014 Dave Sieh. All rights reserved.
//
//  See LICENSE.txt for details.

#import "ViewController.h"
#import "GestureViewController.h"

// Incoming command constants
#define LEFT_TOP_IN 0x10
#define LEFT_BOTTOM_IN 0x11
#define RIGHT_TOP_IN 0x12
#define RIGHT_BOTTOM_IN 0x13

#define SERVO_IN 0x20

// Outbound command constants
#define LIGHT_SENSOR_OUT 0x00
#define SERVO_OUT 0x01

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
    
    IBOutlet UIActivityIndicatorView *aiBusy;
    
    IBOutlet UILabel *lblRSSI;
    
    // States
    BOOL connected;
    
    // Timer to read the rssi value
    NSTimer *rssiTimer;
    
    // The BlueTooth Low Energy object
    BLE *ble;

}

// Bluetooth commands
- (void) sendCommand:(UInt8) cmd
                  b1:(UInt8) b1
                  b2:(UInt8) b2;
- (void)sendResetCommand;
- (void)sendLightSensorCommand:(BOOL)on;
- (void)sendServoCommandHorizontal:(UInt8)horizontal vertical:(UInt8) vertical;

// Inbound Bluetooth commands
- (void) processInboundCommand:(UInt8) cmd
                            b1:(UInt8) b1
                            b2:(UInt8) b2;

- (void) receiveServoCommandWithByte1:(UInt8) b1
                                byte2:(UInt8) b2;

// Timer methods
- (void) readRSSITimer:(NSTimer *)timer;
- (void) connectionTimer:(NSTimer *)timer;

// Private methods
- (void)controlEnabling;
- (void)controlLabelling;
- (UInt16) intFromByte1:(UInt8) b1
                  byte2:(UInt8) b2;
- (NSString *)intStringFromByte1: (UInt8)b1
                     byte2: (UInt8)b2;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    connected = NO;
    
    [self controlEnabling];

    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToGestures"]) {
        // The modal to deal with gestures
        GestureViewController *vc = segue.destinationViewController;
        vc.ble = ble;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark -
#pragma mark BLE Delegate

// Called when connected to the Accessory
- (void) bleDidConnect {
    NSLog(@"bleDidConnect");
    
    // Set the connected state variable
    connected = YES;
    
    // Stop the spinner
    [aiBusy stopAnimating];
    
    [self controlEnabling];
    
    [self controlLabelling];
    
    [self sendResetCommand];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0
                                                 target:self
                                               selector:@selector(readRSSITimer:)
                                               userInfo:nil
                                                repeats:YES];
}

- (void) bleDidDisconnect {
    NSLog(@"bleDidDisconnect");
    
    // Set the connected state variable
    connected = NO;
    
    // Stop the spinner
    [aiBusy stopAnimating];
    
    [self controlEnabling];
    
    [self controlLabelling];
    
    lblRSSI.text = @"---";
    
    // Don't want the timer running anymore. We're
    // disconnected, dude.
    [rssiTimer invalidate];
}

// When RSSI is changed, this will be called
- (void) bleDidUpdateRSSI:(NSNumber *) rssi {
    lblRSSI.text = rssi.stringValue;
}

- (void) bleDidReceiveData:(unsigned char *)data
                    length:(int)length {
    NSLog(@"bleDidReceiveData: %d", length);
    
    // Read the data out of the buffer. All commands are
    // 3 bytes in length
    for (int i = 0; i < length; i += 3) {
        NSLog(@"bleDidReceiveData: 0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        [self processInboundCommand:data[i] b1:data[i+1] b2:data[i+2]];
    }
    
}
#pragma mark -
#pragma mark Timer methods

- (void) readRSSITimer:(NSTimer *)timer {
    [ble readRSSI];
}

- (void) connectionTimer:(NSTimer *)timer {
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect"
                forState:UIControlStateNormal];
    
    // Did we find a peripheral to connect to?
    if (ble.peripherals.count > 0) {
        // Yup. We rock.
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    } else {
        // Nope. Guess we need to try again.
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        [aiBusy stopAnimating];
    }

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
    [ble write:data];
}

- (void)sendResetCommand {
    [self sendLightSensorCommand:YES];
}

- (void)sendLightSensorCommand:(BOOL)on {
    [self sendCommand:LIGHT_SENSOR_OUT b1:((on) ? 0x01 : 0x00) b2:0x00];
}

- (void)sendServoCommandHorizontal:(UInt8)horizontal
                          vertical:(UInt8) vertical {
    [self sendCommand:SERVO_OUT b1:horizontal b2:vertical];
}

#pragma mark -
#pragma mark BlueTooth Inbound Commands

- (void) processInboundCommand:(UInt8) cmd
                            b1:(UInt8) b1
                            b2:(UInt8) b2 {
    
    switch (cmd) {
        case LEFT_TOP_IN:
            tfLeftTop.text = [self intStringFromByte1:b1 byte2:b2];
            break;
            
        case LEFT_BOTTOM_IN:
            tfLeftBottom.text = [self intStringFromByte1:b1 byte2:b2];
            break;
            
        case RIGHT_TOP_IN:
            tfRightTop.text = [self intStringFromByte1:b1 byte2:b2];
            break;
            
        case RIGHT_BOTTOM_IN:
            tfRightBottom.text = [self intStringFromByte1:b1 byte2:b2];
            break;
            
        case SERVO_IN:
            [self receiveServoCommandWithByte1:b1 byte2:b2];
            break;
            
        default:
            break;
    }
}

- (void) receiveServoCommandWithByte1:(UInt8) b1
                                          byte2:(UInt8) b2 {
    stpHorizontal.value = b1;
    sldHorizontal.value = b1;
    tfHorizontal.text = [NSString stringWithFormat:@"%d", b1];
    
    stpVertical.value = b2;
    sldVertical.value = b2;
    tfVertical.text = [NSString stringWithFormat:@"%d", b2];
}

#pragma mark -
#pragma mark Actions

- (IBAction)stpHorizontalChanged:(id)sender {
    float value = stpHorizontal.value;
    sldHorizontal.value = value;
    tfHorizontal.text = [NSString stringWithFormat:@"%d", (int)value];
    [self sendServoCommandHorizontal:(UInt8)sldHorizontal.value
                            vertical:(UInt8)sldVertical.value];
}

- (IBAction)sldHorizontalChanged:(id)sender {
    float value = sldHorizontal.value;
    stpHorizontal.value = value;
    tfHorizontal.text = [NSString stringWithFormat:@"%d", (int)value];
    [self sendServoCommandHorizontal:(UInt8)sldHorizontal.value
                            vertical:(UInt8)sldVertical.value];
}

- (IBAction)stpVerticalChanged:(id)sender {
    float value = stpVertical.value;
    sldVertical.value = value;
    tfVertical.text = [NSString stringWithFormat:@"%d", (int)value];
    [self sendServoCommandHorizontal:(UInt8)sldHorizontal.value
                            vertical:(UInt8)sldVertical.value];
}

- (IBAction)sldVerticalChanged:(id)sender {
    float value = sldVertical.value;
    stpVertical.value = value;
    tfVertical.text = [NSString stringWithFormat:@"%d", (int)value];
    [self sendServoCommandHorizontal:(UInt8)sldHorizontal.value
                            vertical:(UInt8)sldVertical.value];
}

- (IBAction)swLightSensorChanged:(id)sender {
    [self controlEnabling];
    [self sendLightSensorCommand:swLightSensor.on];
}

- (IBAction)btnConnectTouched:(id)sender {
    // For now, we are just going to toggle the connected
    // value.
//    connected = !connected;
//    
//    [self controlLabelling];
//    [self controlEnabling];
    
    // Is there an active peripheral?
    if (ble.activePeripheral) {
        
        // This means we have - at one time - connected to a peripheral
        // Are we actually connected?
        if (ble.activePeripheral.state == CBPeripheralStateConnected) {
            
            // Yes, we are currently connected, disconnect
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    }
    
    // If we get here and have active peripherals, we need to clear them out
    if (ble.peripherals) {
        ble.peripherals = nil;
    }
    
    // Disable the connect button...
    [btnConnect setEnabled:false];
    
    // Tell the BLE stuff to go hunting for a peripheral
    [ble findBLEPeripherals:2];
    
    // Start a timer to fire in 2 seconds to see if we have found
    // a connection
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0
                                     target:self
                                   selector:@selector(connectionTimer:)
                                   userInfo:nil
                                    repeats:NO];
    
    [aiBusy startAnimating];
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

- (UInt16) intFromByte1:(UInt8) b1
                  byte2:(UInt8) b2 {
    return (UInt16)(b2 | b1 << 8);
}


- (NSString *)intStringFromByte1: (UInt8)b1
                           byte2: (UInt8)b2 {
    return [NSString stringWithFormat:@"%d", [self intFromByte1:b1 byte2:b2]];
}

@end
