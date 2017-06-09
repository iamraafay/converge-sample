//
//  NSString+Contains.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ECCContains)

- (BOOL)containsIgnoreCase:(NSString *)otherString;
- (NSUInteger)containsHowManyStrings:(NSString *)otherString;
- (BOOL)containsOnlyAscii;
- (BOOL)containsOnly:(NSCharacterSet *)characters;
- (NSString *)stringContainingOnly:(NSCharacterSet *)characters;
- (NSString *)stringContainingOnlyDigits;

@end
