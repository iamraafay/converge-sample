//
//  KeychainWrapper.h
//  CommerceSample
//
//  Created by Bryan, Edward P on 4/12/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ECCSensitiveData;

@interface KeychainWrapper : NSObject

- (id)init:(NSString *)serviceName;

- (ECCSensitiveData *)getSensitiveDataForKey:(NSString *)key;
- (NSString *)getStringForKey:(NSString *)key;
- (NSData *)getDataForKey:(NSString *)key;
- (void)setString:(NSString *)value forKey:(NSString *)key updateExisting:(BOOL)updateExisting;
- (void)setData:(NSData *)value forKey:(NSString *)key updateExisting:(BOOL)updateExisting;
- (void)removeKey:(NSString *)key;
- (void)clear;

@end