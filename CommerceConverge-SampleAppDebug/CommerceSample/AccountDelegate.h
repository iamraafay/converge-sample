//
//  AccountDelegate.h
//  Commerce Sample
//
//  Created by Mueller, Fabian on 9/23/14.
//  Copyright (c) 2014 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "FlavorIncludes.h"
#import "KeychainWrapper.h"

@interface AccountDelegate : NSObject <ECLAccountDelegate>

-(id)init:(id)mainViewControllerReference;
- (NSString *) userDefault:(NSString *)key;

@property (readonly)KeychainWrapper *userDefaults;

@end
