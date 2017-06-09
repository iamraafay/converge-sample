//
//  NSData+Encoding.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ECCEncoding)

- (NSString *)base64Encode;
- (NSData *)sha1Encode;
+ (NSData *)base64Decode:(NSString *)encoded;

@end
