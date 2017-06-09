//
//  NSNumber+Comparison.h
//  common-ios
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (ECCComparison)

- (BOOL)isGreaterThanZero;
- (BOOL)isEqualToOrLessThanZero;
- (BOOL)isLessThanZero;

@end
