//
//  Args.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECCKeyValuePair;

@interface ECCArgs : NSObject

- (void)addPair:(ECCKeyValuePair *)keyValue;
- (NSArray *)pairs;

@end
