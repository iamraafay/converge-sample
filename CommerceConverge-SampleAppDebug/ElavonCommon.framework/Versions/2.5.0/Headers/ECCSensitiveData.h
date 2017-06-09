//
//  ECCSensitiveData.h
//  Commerce
//
//
//  Copyright (c) 2014 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECCSensitiveDataEditor;
@class ECCSensitiveDataReader;

/// \brief Encrypts data so it can be securely passed around
/// \copyright (c) 2015 Elavon. All rights reserved.
@interface ECCSensitiveData : NSObject

/// \brief This should only be called once. If using Commerce, Commerce will call it for you.
/// \param key Key to used be build encryption key.
+ (void)initialize:(NSUUID *)key;

/// \brief Tells if initialize has been called.
/// \return YES if initialized. NO if not.
+ (BOOL)isInitialized;

/// \brief Constructor for encrypting a string
- (id)init:(NSString *)data;

/// \brief Constructor for base64 encoding a string and then encrypting it
- (id)initWithEncodedString:(NSString *)data;

/// \brief Remove all the data
- (void)clear;

/// \brief Retrieve decrypted string. This should be used only when unable to use 'reader' method. This will cause the secure data to be in
/// \return decrypted string
- (NSString *)string;

/// \brief Retrieve decrypted string and base64 encode it
/// \return decrypted and base64 encoded string
- (NSString *)encodedString;

/// \brief Create a masked string from the encrpyted string using a '*' for mask character
/// \param numbersInClearAtBeginning Numbers of characters that you do not want masked at the beginning of the string
/// \param minimumMasked Minimum number of characters you want masked. This will override numbersInClearAtEnd if it does not allow minimum.
/// \param numbersInClearAtEnd Numbers of characters that you do not want masked at the end of the string
/// \return masked string
- (NSString *)maskedString:(NSUInteger)numbersInClearAtBeginning minimumMasked:(NSUInteger)minimumMasked numbersInClearAtEnd:(NSUInteger)numbersInClearAtEnd;

/// \brief Determine if object passed in is ECCSenstiveData object and encrypts the same data.
/// \return YES if equal. NO if not.
- (BOOL)isEqual:(id)object;

/// \brief Return an editor of data so you do not have to decrypt full string to edit.
/// \return editor to change data inside this ECCSensitiveData instance
- (ECCSensitiveDataEditor *)editor;

/// \brief Return an reader of data so you do not have to decrypt full string to edit.
/// \return reader to read data inside this ECCSensitiveData instance
- (ECCSensitiveDataReader *)reader;

/// \brief Return length of decrypted string
/// \return length of descrypted string
- (NSUInteger)length;

@end

/// \brief Helper class for ECCSensitiveData to allow reading one character at a time so data is never decrypted fully.
/// \copyright (c) 2015 Elavon. All rights reserved.
@interface ECCSensitiveDataReader : NSObject

- (id)init:(ECCSensitiveData *)data;
/// \brief Return length of decrypted string
/// \return length of descrypted string
- (NSUInteger)length;
/// \brief Return character at index
/// \param at index of character you want returned
/// \return character at index
- (unichar)characterAt:(NSUInteger)at;

@end

/// \brief Helper class for ECCSensitiveData to allow editing data so it is never decrypted fully.
/// \copyright (c) 2015 Elavon. All rights reserved.
@interface ECCSensitiveDataEditor : NSObject

- (id)init;
- (id)init:(ECCSensitiveData *)data;
/// \brief clear all data
- (void)clear;
/// \brief Return character at index
/// \param at index of character you want returned
/// \return character at index
- (unichar)at:(NSUInteger)at;
/// \brief Append character to end of data
/// \param character character to append
- (void)append:(unichar)character;
/// \brief Replace each character in range with specified character
/// \param character character to use for replacement
/// \param range Range of characters to replace
- (void)replace:(unichar)character range:(NSRange)range;
/// \brief Remove the range of characters
/// \param range Range of characters to remove
- (void)removeRange:(NSRange)range;
/// \brief Return length of decrypted string
/// \return length of descrypted string
- (NSUInteger)length;
/// \brief Return ECCSensitiveData being edited
/// \return instance being edited
- (ECCSensitiveData *)data;

@end
