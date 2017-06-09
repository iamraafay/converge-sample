//
//  SoapObject.h
//  MobileMerchant
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECCSoapObject : NSObject 

- (id)init:(NSString *)name;
- (NSString *)name;
- (void)addValue:(NSString *)value;
- (void)addChild:(ECCSoapObject *)child;
- (NSString *)value;
- (NSArray *)children;
- (ECCSoapObject *)childByName:(NSString *)name;
- (ECCSoapObject *)descendantByName:(NSString *)name;
- (ECCSoapObject *)referral;
- (void)updateLinks:(NSDictionary *)idsToObjects;

@end
