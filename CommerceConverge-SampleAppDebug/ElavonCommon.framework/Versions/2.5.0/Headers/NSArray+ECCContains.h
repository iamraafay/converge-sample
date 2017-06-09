//
//  NSArray+Contains.h
//  ElavonCommon
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ECCContains)

- (BOOL)containsObjectPassingTest:(BOOL (^)(id obj))test;

@end
