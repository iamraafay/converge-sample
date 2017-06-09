//
//  RefreshStatusViewController.m
//  CommerceSample
//
//  Created by Phan, Trac B on 6/20/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RefreshStatusViewController.h"
#import "Flavor.h"
#import "ServerNames.h"

@interface RefreshStatusViewController ()

@property id<ECLAccountDelegate> delegate;
@property id<ECLDevicesProtocol> saveAvailableDevices;
@property NSArray *saveSearchResults;;

@end

@implementation RefreshStatusViewController


- (void) passMainViewController: (MainViewController *) controller{
    _mainViewController = controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _refreshButton.enabled = NO;

    [_availableDevices removeAllSegments];
    
    id <ECLCardReaderProtocol> cardReader = _mainViewController.cardReader;
    if (cardReader != nil) {

        NSUInteger index = 0;
        NSUInteger savedIndex = 0;
        [_availableDevices insertSegmentWithTitle:cardReader.name atIndex:index++ animated:NO];
        savedIndex = index - 1;

        [self.availableDevices setSelectedSegmentIndex:savedIndex];
        _refreshButton.enabled = YES;

    } else {
        [_availableDevices insertSegmentWithTitle:@"No Devices" atIndex:0 animated:NO];
    }
}
- (IBAction)refreshButtonClicked:(id)sender {
    id <ECLCardReaderProtocol> cardReader = _mainViewController.cardReader;
    if (cardReader != nil) {
        [_mainViewController addStatusString:[NSString stringWithFormat:@"Refreshing Status ...\n"]];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [cardReader refreshStatus];
        });
    } else {
        [_mainViewController addStatusString:@"No card reader connected.\n"];
    }
}

- (NSString *)connectionStatusToString:(ECLDeviceConnectionState) connectionStatus {
    switch(connectionStatus) {
        case ECLDeviceConnectionState_Connected:
            return @"Connected";
        case ECLDeviceConnectionState_Disconnected:
            return @"Disconnected";
        case ECLDeviceConnectionState_ConnectedNotReady:
            return @"Connected Not Ready";
        case ECLDeviceConnectionState_Unknown:
            return @"Unknown";
        case ECLDeviceConnectionState_UnSet:
            return @"UnSet";
    }
}

- (NSString *)batteryChargingStateToString:(ECLDeviceBatteryChargingState) chargingState {
    switch(chargingState) {
        case ECLDeviceBatteryChargingState_Charging:
            return @"Charging";
        case ECLDeviceBatteryChargingState_ChargingUsb:
            return @"Charging Usb";
        case ECLDeviceBatteryChargingState_ChargingAc:
            return @"Charging AC";
        case ECLDeviceBatteryChargingState_Discharging:
            return @"Discharging";
        case ECLDeviceBatteryChargingState_Unknown:
            return @"Unknown";
        case ECLDeviceBatteryChargingState_UnSet:
            return @"UnSet";
    }
}

- (NSString *)batteryLevelToString:(ECLDeviceBatteryChargeLevelState) batteryLevel {
    switch(batteryLevel) {
        case ECLDeviceBatteryChargeLevelState_Full:
            return @"Full";
        case ECLDeviceBatteryChargeLevelState_Good:
            return @"Good";
        case ECLDeviceBatteryChargeLevelState_Low:
            return @"Low";
        case ECLDeviceBatteryChargeLevelState_Critical:
            return @"Critical";
        case ECLDeviceBatteryChargeLevelState_Unknown:
            return @"Unknown";
        case ECLDeviceBatteryChargeLevelState_UnSet:
            return @"UnSet";
    }
}

- (void)deviceConnectionStateChanged:(id<ECLDeviceProtocol>)device deviceConnectionState:(ECLDeviceConnectionState)deviceConnectionState {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Card reader %@ is %@\n", [(id<ECLCardReaderProtocol>)device name ], [self connectionStatusToString:deviceConnectionState]]];
}

- (void)devicePowerStateChanged:(id<ECLDeviceProtocol>)device devicePowerState:(ECLDevicePowerState *)devicePowerState {
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charge level: %@\n", [(id<ECLCardReaderProtocol>)device name], [[devicePowerState batteryChargeLevel] chargeLevel]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charge state: %@\n", [(id<ECLCardReaderProtocol>)device name], [self batteryLevelToString:[[devicePowerState batteryChargeLevel] chargeLevelState]]]];
    [_mainViewController addStatusString:[NSString stringWithFormat:@"Card reader %@  battery charging state: %@\n", [(id<ECLCardReaderProtocol>)device name], [self batteryChargingStateToString:[devicePowerState batteryChargingState]]]];
}

- (void)refreshStatusDidFail:(id<ECLDeviceProtocol>)device errors:(NSArray *)arrayOfNSErrors {
}

@end
