//
//  Transport.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import "ECCRequest.h"
#import "ECCTransportInfo.h"

@class ECCUrl;

@protocol ECCRequestTransportReceiver

- (void)requestDone:(ECCRequest *)request;
- (void)requestCancelled:(ECCRequest *)request;
- (void)requestNotIssued:(ECCRequest *)request error:(NSError *)error;

@end

typedef ECCUrl *(^blockURL_t)(void);
typedef ECCSensitiveData *(^blockSensitiveData_t)(void);

@interface ECCTransport : NSObject

- (id)init:(id<ECCTransportInfo>)theCredentials;
- (id)initWithURLBlock:(blockURL_t)urlBlock usernameBlock:(blockSensitiveData_t)usernameBlock passwordBlock:(blockSensitiveData_t)passwordBlock;
- (BOOL)issueRequest:(ECCRequest *)request receiver:(id<ECCRequestTransportReceiver>)requestReceiver;
- (void)cancelAllRequests;
- (void)cancelRequestsForClass:(Class)requestClass;

@end
