//
//  CC-AccountDelegate.h
//  Commerce Sample
//
//  Created by Mueller, Fabian on 9/23/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountDelegate.h"
#import <Commerce-CreditCall/ECLAccountProtocol.h>
#import <ElavonCommon/ECCSensitiveData.h>
#import <Commerce-CreditCall/ECLCreditCallAccountDelegate.h>

@interface CreditCallAccountDelegate : AccountDelegate <ECLCreditCallAccountDelegate>

- (NSString *) getTerminalID;
- (NSString *) getTransactionKey;
- (NSString *) getUsername;
- (NSString *) getPassword;
- (NSString *) getApplicationId;
@end
