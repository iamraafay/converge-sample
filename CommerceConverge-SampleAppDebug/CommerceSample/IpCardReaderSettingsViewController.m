//
//  IpCardReaderSettingsViewController.m
//  CommerceSample
//
//  Created by Phan, Trac B on 7/22/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommerceDataTypes/ECLConnectionConfiguration.h>
#import <CommerceDataTypes/ECLConnectionMethod.h>
#import <CommerceDataTypes/ECLInetAddress.h>
#import <CommerceDataTypes/ECLEncryptionScheme.h>

#import "IpCardReaderSettingsViewController.h"
#import "Flavor.h"

#define CARD_READER_INTERNET_CONNECTION @"ipCardReaderInternetConnection"
#define CARD_READER_UNKNOWN_CONNECTION  @"ipCardReaderUnknownConnection"

@interface IpCardReaderSettingsViewController ()

@end

@implementation IpCardReaderSettingsViewController

- (void) passMainViewController: (MainViewController *) controller{
    _mainViewController = controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add a gesture recognizer so when they tap outside keyboard it goes away
    UIGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];

    if (ipCardReaderConfiguration.connectionMethod == ECLConnectionMethod_Internet) {
        [_ipSwitch setOn:YES];
        _ipAddressTextField.enabled = YES;
        _portTextField.enabled = YES;

		ECLInetAddress * inetAddress = ipCardReaderConfiguration.inetAddress;
		if (nil != inetAddress)
		{
			_ipAddressTextField.text = inetAddress.host;
			_portTextField.text = [inetAddress.port stringValue];
            [_securedSwitch setOn:inetAddress.encryptionScheme != ECLEncryptionScheme_NONE];
		}
    } else {
        [_ipSwitch setOn:NO];
        _ipAddressTextField.enabled = NO;
        _portTextField.enabled = NO;
        _securedSwitch.enabled = NO;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    // stop editing text so keyboard dimisses
    [self.view endEditing:YES];
}

- (IBAction)connectionTypeClicked:(id)sender {
    if ([_ipSwitch isOn])
    {
    	ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];
		ECLInetAddress * inetAddress = ipCardReaderConfiguration.inetAddress;
		if (nil != inetAddress)
		{
			_ipAddressTextField.text = inetAddress.host;
			_portTextField.text = [inetAddress.port stringValue];
            [_securedSwitch setOn:inetAddress.encryptionScheme != ECLEncryptionScheme_NONE animated:YES];
		}

        
        _ipAddressTextField.enabled = YES;
        _portTextField.enabled = YES;
        _securedSwitch.enabled = YES;
    }
    else
    {
        _ipAddressTextField.text = @"";
        _portTextField.text = @"";
        _ipAddressTextField.enabled = NO;
        _portTextField.enabled = NO;
        _securedSwitch.enabled = NO;
    }
}

- (IBAction)saveButtonClicked:(id)sender {
    [self setReaderConnectionConfig];
}

- (void) setReaderConnectionConfig
{
    ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];
    
    if ([_ipSwitch isOn])
    {
        NSString * encryptionSchemeText = [_securedSwitch isOn]? @"ECLEncryptionScheme_TLS_12" : @"ECLEncryptionScheme_NONE";
        [self addStatusString:[NSString stringWithFormat:@"IP card reader is set to %@ : %@ (%@)\n", _ipAddressTextField.text, _portTextField.text, encryptionSchemeText]];
        ipCardReaderConfiguration.connectionMethod = ECLConnectionMethod_Internet;
        
        ECLInetAddress * inetAddress = [[ECLInetAddress alloc] initWithHostAndClientCerficateInfo:_ipAddressTextField.text
                                                                                             port:[NSNumber numberWithInteger:[_portTextField.text integerValue]]
                                                                                 encryptionScheme:[_securedSwitch isOn]? ECLEncryptionScheme_TLS_12 : ECLEncryptionScheme_NONE
                                                                                clientPFXFilePath:@"CLIENT"
                                                                                  pfxFilePasscode:@"password"];
        [self updateConfiguration:CARD_READER_INTERNET_CONNECTION inetAddress:inetAddress];
    }
    else
    {
        [self addStatusString:[NSString stringWithFormat:@"Audio: IP card reader configuration is clear\n"]];
        [self updateConfiguration:CARD_READER_UNKNOWN_CONNECTION inetAddress:nil];
    }
}

- (void)updateConfiguration:(NSString *)connectionType inetAddress: (ECLInetAddress *)inetAddress {
    
    ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];
    if ([connectionType  isEqual: CARD_READER_INTERNET_CONNECTION])
	{
        ipCardReaderConfiguration.connectionMethod = ECLConnectionMethod_Internet;
        ipCardReaderConfiguration.inetAddress = inetAddress;
    }
	else
	{
        ipCardReaderConfiguration.connectionMethod = ECLConnectionMethod_Audio;
    }
    [_mainViewController.accountDelegate saveIpCardReaderConfiguration];
    
}

- (void)addStatusString:(NSString *)text {
    if (text == nil) {
        return;
    }
    NSString *origText = _statusLabel.text;
    _statusLabel.text = [origText stringByAppendingString:text];
    if (_statusLabel.text.length > 0)
    {
        NSRange range = NSMakeRange(_statusLabel.text.length - 1, 1);
        [_statusLabel scrollRangeToVisible:range];
    }
}

@end
