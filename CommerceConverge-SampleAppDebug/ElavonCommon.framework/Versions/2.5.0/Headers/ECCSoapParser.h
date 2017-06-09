//
//  SoapParser.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECCSoapObject;

@interface ECCSoapParser : NSObject <NSXMLParserDelegate>

- (ECCSoapObject *)parse:(NSData *)envelope;

@end
