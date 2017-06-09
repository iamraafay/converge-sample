//
//  AccountDelegate.m
//  Commerce Sample
//
//  Created by Mueller, Fabian on 9/23/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "AccountDelegate.h"
#import "MainViewController.h"
#import <CommerceDataTypes/ECLConnectionMethod.h>
#import "OurUserDefaults.h"


#define APPID   @"iOS_SA" // 8 character MAX length

// If I ever want to start over, change the service name
#define SERVICE_NAME @"com.elavon.commerce.sampleapp_1"
#define CARD_READER_CONNECTION_TYPE     @"ipCardReaderConnectionType"
#define CARD_READER_INTERNET_CONNECTION @"ipCardReaderInternetConnection"
#define CARD_READER_UNKNOWN_CONNECTION  @"ipCardReaderUnknownConnection"
#define CARD_READER_IP_ADDRESS          @"ipCardReaderAddress"
#define CARD_READER_PORT                @"ipCardReaderPort"
#define CARD_READER_IP_ENCRYPTION_SCHEME @"ipCardReaderEncryptionScheme"


@interface AccountDelegate()

@property (nonatomic) MainViewController* mainViewControllerReference;

@end

@implementation AccountDelegate

@synthesize mainViewControllerReference = _mainViewControllerReference;


-(id)init:(id)mainViewControllerReference {
    
    self = [super init];
    
    if (self)
    {
        _mainViewControllerReference = mainViewControllerReference;
        _userDefaults = [[KeychainWrapper alloc] init:SERVICE_NAME];
        NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"firstRun"];
        if (savedValue == nil) {
            [[NSUserDefaults standardUserDefaults] setValue:@"no" forKey:@"firstRun"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // since the key was not in userdefaults the app was deleted or first time run so clear all the keychain settings
            [_userDefaults clear];
            // set default for serverType to DEMO
            [_userDefaults setString:[ECLDebugDescriptions descriptionOfServerTypes:ECLServerType_Demo] forKey:@"serverType" updateExisting:YES];
        }
    }
    
    return self;
}


// we can start using the account when this is called
- (void)accountDidInitialize:(id<ECLAccountProtocol>)account {
    
    self.mainViewControllerReference.account = account;
    [account setUpdateKeysDelegate:self.mainViewControllerReference];
}

// problem creating account
- (void)accountDidFailToInitialize:(id<ECLAccountProtocol>)account error:(NSError *)error {

    self.mainViewControllerReference.statusLabel.text = [NSString stringWithFormat:@"account initialization failed: %@\n",[error debugDescription]];
}

- (void)defaultCurrencyDidChange:(id<ECLAccountProtocol>)account defaultCurrencyCode:(ECLCurrencyCode)defaultCurrencyCode {
    self.mainViewControllerReference.defaultCurrencyCode = defaultCurrencyCode;
    [self.mainViewControllerReference fillSegmentControls];
}

// this will be overridden in Flavor.m. just here to suppress warning
- (ECLServerType)serverType:(id<ECLAccountProtocol>)account {
    return ECLServerType_Demo;
}
- (NSString *) userDefault:(NSString *)key{
    return [_userDefaults getStringForKey:key];
}

- (void) loadIpCardReaderConfiguration {
    ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];
    if ([[_userDefaults getStringForKey:CARD_READER_CONNECTION_TYPE]  isEqual: CARD_READER_INTERNET_CONNECTION]) {
        ipCardReaderConfiguration.connectionMethod = ECLConnectionMethod_Internet;
    }
    NSString * ipAddress = [_userDefaults getStringForKey:CARD_READER_IP_ADDRESS];
    NSNumber *port = [NSNumber numberWithInteger: [[_userDefaults getStringForKey:CARD_READER_PORT] integerValue]];
    
    ECLInetAddress * inetAddress = [[ECLInetAddress alloc] initWithHostAndClientCerficateInfo:ipAddress
                                                                                         port:port
                                                                             encryptionScheme:[OurUserDefaults eclEncryptionSchemeTypeStringToEnum:[_userDefaults getStringForKey:CARD_READER_IP_ENCRYPTION_SCHEME]]
                                                                            clientPFXFilePath:@"CLIENT"
                                                                              pfxFilePasscode:@"password"];
    
	ipCardReaderConfiguration.inetAddress = inetAddress;
    
}

- (void) saveIpCardReaderConfiguration {
    ECLConnectionConfiguration *ipCardReaderConfiguration = [ECLConnectionConfiguration sharedInstance];
    NSString *connectionType = CARD_READER_UNKNOWN_CONNECTION;
    if (ipCardReaderConfiguration.connectionMethod == ECLConnectionMethod_Internet) {
        connectionType = CARD_READER_INTERNET_CONNECTION;
    }
    [_userDefaults setString:connectionType forKey:CARD_READER_CONNECTION_TYPE updateExisting:YES];
	ECLInetAddress * inetAddress = ipCardReaderConfiguration.inetAddress;
	if (nil != inetAddress)
	{
		[_userDefaults setString:inetAddress.host forKey:CARD_READER_IP_ADDRESS updateExisting:YES];
		[_userDefaults setString:[inetAddress.port stringValue] forKey:CARD_READER_PORT updateExisting:YES];
        
        NSString * encryptionSchemeStringValue = [OurUserDefaults eclEncryptionSchemeTypeEnumToString:inetAddress.encryptionScheme];
        
        [_userDefaults setString:encryptionSchemeStringValue forKey:CARD_READER_IP_ENCRYPTION_SCHEME updateExisting:YES];
	}
}

@end
