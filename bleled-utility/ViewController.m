//
//  ViewController.m
//  bleled-utility
//
//  Created by William Black on 3/23/16.
//  Copyright © 2016 William Black. All rights reserved.
//

#import "ViewController.h"
#import <ARMSerialWireDebug/FDSerialEngine.h>
#import <ARMSerialWireDebug/FDSerialWireDebug.h>
#import <ARMSerialWireDebug/FDUSBDevice.h>
#import <ARMSerialWireDebug/FDUSBMonitor.h>

@interface ViewController() <FDUSBMonitorDelegate>

@property FDUSBMonitor *usbMonitor;
@property NSObject *serialWireDebugNRFUSBLocation;
@property FDUSBMonitorMatcherVidPid *serialWireDebugMatcher;
@property FDSerialWireDebug *serialWireDebug;
@property FDUSBDevice *bleledDevice;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _serialWireDebugMatcher = [FDUSBMonitorMatcherVidPid matcher:@"olimex serial wire debug" vid:0x15ba pid:0x002a];
    _usbMonitor = [[FDUSBMonitor alloc] init];

    _usbMonitor.matchers = @[_serialWireDebugMatcher];
    
    _usbMonitor.delegate = self;
    [_usbMonitor start];

    //[self doStuff];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)usbMonitor:(FDUSBMonitor *)usbMonitor usbDeviceAdded:(FDUSBDevice *)device {
    NSLog(@"found a device");
    if ([_serialWireDebugMatcher matches:device.deviceInterface]) {
        _serialWireDebugNRFUSBLocation = device.location;
        _bleledDevice = device;
        NSLog(@"Found SWD");
    }
}

- (void)usbMonitor:(FDUSBMonitor *)usbMonitor usbDeviceRemoved:(FDUSBDevice *)device {
}

- (FDSerialWireDebug *)newSerialWireDebug:(FDUSBDevice *)usbDevice {
    [usbDevice open];
    
    FDSerialEngine *serialEngine = [[FDSerialEngine alloc] init];
    serialEngine.timeout = 3;
    serialEngine.usbDevice = usbDevice;
    FDSerialWireDebug *serialWireDebug = [[FDSerialWireDebug alloc] init];
    serialWireDebug.maskInterrupts = YES;
    serialWireDebug.serialEngine = serialEngine;
    [serialWireDebug initialize];
    [serialWireDebug setGpioIndicator:NO];
    [serialWireDebug setClockDivisor:10];
    return serialWireDebug;
}

- (IBAction)pressButton:(id)sender {
    [self doStuff];
}

- (void)doStuff {
    NSLog(@"opening serial wire debug connection to NRF...");
    _serialWireDebug = [self newSerialWireDebug:_bleledDevice];
    
    NSData *verify = [_serialWireDebug readMemory:0x00 length:0xff];
    NSLog(@"%@", verify);
}

@end
