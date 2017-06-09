//
//  ECCUrl.h
//  ElavonCommon
//
//  Copyright (c) 2015 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCUrl : NSObject

- (id)initWithUrl:(NSURL *)url external:(BOOL)external;

@property (readonly)NSURL *url;
@property (readonly)BOOL external;
@end
