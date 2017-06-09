//
//  NSDecimalNumber+ECCMinorUnits.h
//  common-ios
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDecimalNumber (ECCMinorUnits)

+ (NSDecimalNumber *)decimalNumberFromMinorUnits:(NSInteger)minorUnits exponent:(short)exponent;
+ (NSNumber *)minorUnitsNumber:(NSNumber *)number withScale:(short)scale;
+ (long)minorUnitsLong:(NSNumber *)number withScale:(short)scale;

@end
