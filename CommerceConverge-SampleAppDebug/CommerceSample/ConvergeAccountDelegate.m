//
//  VM-AccountDelegate.m
//  Commerce Sample
//
//  Created by Mueller, Fabian on 9/25/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import "ConvergeAccountDelegate.h"
#import "ServerNames.h"

@implementation ConvergeAccountDelegate

- (ECCSensitiveData *)merchantId:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"merchantID"];
}

- (ECCSensitiveData *)userId:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"userID"];
}

- (ECCSensitiveData *)pin:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"pin"];
}

- (ECCSensitiveData *)vendorId:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"vendorID"];
}

- (ECCSensitiveData *)vendorAppName:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"vendorAppName"];
}

- (ECCSensitiveData *)vendorAppVersion:(id<ECLAccountProtocol>)account {
    return [self.userDefaults getSensitiveDataForKey:@"vendorAppVersion"];
}


- (ECLServerType)serverType:(id<ECLAccountProtocol>)account {
    NSString *serverSaved = [self.userDefaults getStringForKey:@"serverType"];
    if ([serverSaved caseInsensitiveCompare:SERVER_NAME_PRODUCTION] == 0) {
        return ECLServerType_Production;
    }
    if ([serverSaved caseInsensitiveCompare:SERVER_NAME_DEV] == 0) {
        return ECLServerType_Development;
    }
    if ([serverSaved caseInsensitiveCompare:SERVER_NAME_QA] == 0) {
        return ECLServerType_QA;
    }
    if ([serverSaved caseInsensitiveCompare:SERVER_NAME_UAT] == 0) {
        return ECLServerType_UAT;
    }
    if ([serverSaved caseInsensitiveCompare:SERVER_NAME_ALPHA] == 0) {
        return ECLServerType_Alpha;
    }
    return ECLServerType_Demo;
}
@end
