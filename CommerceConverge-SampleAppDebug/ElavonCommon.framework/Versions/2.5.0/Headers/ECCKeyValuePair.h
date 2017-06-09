//
//  KeyValuePair.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCKeyValuePair : NSObject

+ (ECCKeyValuePair *)key:(id)key value:(id)value;
- (id)key;
- (id)value;
- (void)setValue:(id)value;

@end
