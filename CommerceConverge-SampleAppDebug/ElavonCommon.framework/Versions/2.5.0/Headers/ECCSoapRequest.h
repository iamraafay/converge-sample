//
//  SoapRequest.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <ElavonCommon/ECCRequest.h>

@interface ECCSoapRequest : ECCRequest

- (id)init:(NSString *)theAction timeout:(NSTimeInterval)theTimeout;
- (NSString *)action;

@end
