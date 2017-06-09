//
//  CC-AccountDelegate.m
//  Commerce Sample
//
//  Created by Mueller, Fabian on 9/23/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "CreditCallAccountDelegate.h"
#import <ElavonCommon/ECCSensitiveData.h>

// these should be settings for your merchant's account
#define TERMINAL_ID                 @""
#define TRANSACTION_KEY             @""
#define USERNAME                    @""
#define PASSWORD                    @""
#define SOAPPASSWORD                @""
#define SOAPUSERNAME                @""
#define APPID                       @"MyCoolApp"
#define DBPASSWORD                  @"dbpassword"
#define EMAIL                       @"hello@world.com"
#define NAME                        @"Hello World, Inc"


@implementation CreditCallAccountDelegate

NSString *terminalID = TERMINAL_ID;
NSString *transactionKey = TRANSACTION_KEY;
NSString *webMisUser = USERNAME;
NSString *webMisPassword = PASSWORD;
NSString *applicationId = APPID;

/// \brief Commerce requires a password to access the database
/// \return The password
- (ECCSensitiveData *)databasePassword:(id<ECLAccountProtocol>)account {
    // This should be protected information. Maybe a stored securally hashed.
    return [[ECCSensitiveData alloc] init:DBPASSWORD];
}

/// \brief Commerce requires the terminal id
/// \return The terminal id
- (ECCSensitiveData *)terminalId:(id<ECLAccountProtocol>)account {
    return [[ECCSensitiveData alloc] init:[self.userDefaults getStringForKey:@"terminalID"]];
}

/// \brief Commerce requires the transaction key
/// \return The transaction key
- (ECCSensitiveData *)transactionKey:(id<ECLAccountProtocol>)account terminalId:(ECCSensitiveData *)terminalId {
    return [[ECCSensitiveData alloc] init:[self.userDefaults getStringForKey:@"transactionKey"]];
}

/// \brief Commerce requires the WebMis username
/// \return The username
- (ECCSensitiveData *)webMisUser:(id<ECLAccountProtocol>)account {
    return [[ECCSensitiveData alloc] init:[self.userDefaults getStringForKey:@"webMisUser"]];
}

/// \brief Commerce requires the WebMis password
/// \return The password
- (ECCSensitiveData *)webMisPassword:(id<ECLAccountProtocol>)account {
    return [[ECCSensitiveData alloc] init:[self.userDefaults getStringForKey:@"webMisPassword"]];
}

/// \brief Commerce requires the SOAP username for either a live or test server
/// \return The SOAP username
- (ECCSensitiveData *)soapUser:(id<ECLAccountProtocol>)account liveServer:(BOOL)isLive {
    // your applications soap username to the web mis server
    return [[ECCSensitiveData alloc] init:SOAPUSERNAME];
}

/// \brief Commerce requires the SOAP password for either a live or test server
/// \return The SOAP password
- (ECCSensitiveData *)soapPassword:(id<ECLAccountProtocol>)account liveServer:(BOOL)isLive {
    // your applications soap username to the web mis server
     return [[ECCSensitiveData alloc] init:SOAPPASSWORD];
}

/// \brief Credit Call requires an identifier for your application
/// \return The app id
- (ECCSensitiveData *)applicationId:(id<ECLAccountProtocol>)account {
    return [[ECCSensitiveData alloc] init:APPID];
}

- (NSString *) getTerminalID{
    return terminalID;
}
- (NSString *) getTransactionKey{
    return transactionKey;
}
- (NSString *) getUsername{
    return webMisUser;
}
- (NSString *) getPassword{
    return webMisPassword;
}
- (NSString *) getApplicationId{
    return applicationId;
}
- (ECLServerType)serverType:(id<ECLAccountProtocol>)account {
    NSString *serverSaved = [self.userDefaults getStringForKey:@"serverType"];
    if ([serverSaved caseInsensitiveCompare:[ECLDebugDescriptions descriptionOfServerTypes:ECLServerType_Production]] == 0) {
        return ECLServerType_Production;
    }
    return ECLServerType_Demo;
}

- (NSString *)businessEmail:(id<ECLAccountProtocol>)account {
    return EMAIL;
}
@end
