//
//  TransportInfo.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ECCSensitiveData;
@class ECCUrl;

@protocol ECCTransportInfo <NSObject>

@required
- (ECCUrl *)url;

@optional
- (ECCSensitiveData *)username;
- (ECCSensitiveData *)password;

@end
