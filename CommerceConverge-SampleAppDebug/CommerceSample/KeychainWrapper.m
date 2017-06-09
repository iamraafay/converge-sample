//
//  KeychainWrapper.m
//  CommerceSample
//
//  Created by Bryan, Edward P on 4/12/16.
//  Copyright © 2016 Elavon. All rights reserved.
//

#import "KeychainWrapper.h"
#import <Security/Security.h>
#import <ElavonCommon/ECCSensitiveData.h>

#define WRAP_KEYCHAIN_ERROR_DOMAIN @"commerceSampleAppKeychainErrorDomain"

@interface KeychainWrapper() {
@private
    NSString *serviceName;
}
@end

@implementation KeychainWrapper

- (id)init:(NSString *)theServiceName {
    self = [super init];
    if (self) {
        serviceName = theServiceName;
    }
    return self;
}

- (void)clear {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    //    [dict setObject:(__bridge id)serviceName forKey:(__bridge id)kSecAttrService];
    SecItemDelete((__bridge CFDictionaryRef) dict);
}

- (ECCSensitiveData *)getSensitiveDataForKey:(NSString *)key {
    NSData *stringData = [self getDataForKey:key];
    if (stringData) {
        NSString *string = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
        return [[ECCSensitiveData alloc] init:string];
    } else {
        return nil;
    }
    
}

- (NSString *)getStringForKey:(NSString *)key {
    NSData *stringData = [self getDataForKey:key];
    if (stringData) {
        return [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
    
}

- (NSData *)getDataForKey:(NSString *)key {
    NSData *foundData = nil;
    if (key && serviceName) {
        // Create query dictionary with the base query attributes: item type (generic), username, and service
        NSArray *keys = [[NSArray alloc]initWithObjects:(__bridge_transfer NSString *)kSecClass,
                         kSecAttrAccount, kSecAttrService, nil];
        NSArray *objects = [[NSArray alloc]initWithObjects:(__bridge_transfer NSString *)kSecClassGenericPassword,
                            key, serviceName, nil];
        NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
        BOOL validated = [self validateQuery:query];
        if (validated == YES) {
            // Query for the value data associated with the key; since it does exist after previous validation
            NSMutableDictionary *passwordQuery = [query mutableCopy];
            [passwordQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
            CFTypeRef resData = NULL;
            OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) passwordQuery, (CFTypeRef *) &resData);
            NSData *resultData = (__bridge_transfer NSData *)resData;
            
            if (status != noErr) {
                if (status == errSecItemNotFound) {
                    resultData = nil;
                }
            } else {
                foundData = resultData;
            }
        }
    }
    
    return foundData;
}

- (void)setString:(NSString *)value forKey:(NSString *)key updateExisting:(BOOL)updateExisting {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [self setData:data forKey:key updateExisting:updateExisting];
}

- (void)setData:(NSData *)value forKey:(NSString *)key updateExisting:(BOOL)updateExisting {
    if (key && serviceName && value == nil) {
        [self removeKey:key];
    } else if (key && value && serviceName) {
        // Query, if already data entered for the attribute
        NSData *existingValue = [self getDataForKey:key];
        
        if (existingValue == nil) {
            // just in case we failed to get it because of error
            [self removeKey:key];
            [self setData:value forKey:key];
        } else {
            if (updateExisting && ![existingValue isEqualToData:value]) {
                [self updateData:value forKey:key];
            }
        }
    }
}

- (void)setData:(NSData *)value forKey:(NSString *)key {
    NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge_transfer NSString *) kSecClass,
                     kSecAttrService,
                     kSecAttrLabel,
                     kSecAttrAccount,
                     kSecValueData,
                     nil];
    
    NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge_transfer NSString *) kSecClassGenericPassword,
                        serviceName,
                        serviceName,
                        key,
                        value,
                        nil];
    
    NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    SecItemAdd((__bridge CFDictionaryRef) query, NULL);
}

- (void)updateData:(NSData *)value forKey:(NSString  *)key {
    NSArray *keys = [[NSArray alloc] initWithObjects:
                     (__bridge_transfer NSString *) kSecClass,
                     kSecAttrService,
                     kSecAttrLabel,
                     kSecAttrAccount,
                     nil];
    
    NSArray *objects = [[NSArray alloc] initWithObjects:
                        (__bridge_transfer NSString *) kSecClassGenericPassword,
                        serviceName,
                        serviceName,
                        key,
                        nil];
    
    NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    NSDictionary *itemDictionary = [NSDictionary dictionaryWithObject:value
                                                               forKey:(__bridge_transfer NSString *) kSecValueData];
    SecItemUpdate((__bridge CFDictionaryRef)query,
                                    (__bridge CFDictionaryRef)itemDictionary);
}

- (void)removeKey:(NSString *)key {
    if (key && serviceName) {
        NSArray *keys = [[NSArray alloc] initWithObjects:(__bridge_transfer NSString *) kSecClass,
                         kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil];
        NSArray *objects = [[NSArray alloc] initWithObjects:(__bridge_transfer NSString *)
                            kSecClassGenericPassword, key, serviceName, kCFBooleanTrue, nil];
        
        NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
        
        SecItemDelete((__bridge CFDictionaryRef) query);
    }
}

- (BOOL)validateQuery:(NSDictionary *)query {
    BOOL validated = YES;
    // Query for attribute
    NSMutableDictionary *attributeQuery = [query mutableCopy];
    [attributeQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnAttributes];
    CFTypeRef attrResult = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) attributeQuery, &attrResult);
    if (status != noErr && status != errSecItemNotFound) {
        validated = NO; 
    }
    if (attrResult) {
        CFRelease(attrResult);
    }
    return validated;
}

@end