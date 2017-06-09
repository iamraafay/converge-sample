//
//  Request.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCRequest : NSObject

- (id)init:(NSTimeInterval)theTimeout contentType:(NSString *)contentType;
- (NSTimeInterval)timeout;
- (NSData *)content;
- (NSString *)contentType;
- (void)setResponseContentType:(NSString *)contentType;
- (void)setResponseStatus:(NSInteger)code;
- (NSInteger)responseStatus;
- (BOOL)canAcceptResponse;
- (void)processResponse:(NSData *)data;
- (void)resetResponse;
- (void)failed:(NSError *)error;
- (NSError *)error;
- (BOOL)canAcceptResponse:(NSInteger)responseCode contentType:(NSString *)contentType;

@end
