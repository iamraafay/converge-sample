#import <Foundation/Foundation.h>
#import <CommerceDataTypes/ECLCurrencyCode.h>

/// \brief Helper class for ::ECLCurrencyCode.
/// \copyright (c) 2016 Elavon. All rights reserved.
@interface ECLCurrencyCodeUtil : NSObject

/// \brief Calculates the number of fraction digits (digits to right of decimal) for the specified currency code
///  \param currencyCode The ECLCurrencyCode value to get fraction digits for.
///  \return The number of fraction digits.
+ (NSUInteger)fractionDigitsForCurrencyCode:(ECLCurrencyCode)currencyCode;

/// \brief Returns a ECLCurrencyCode for the string value passed in (ISO 4217)
/// \param currencyCodeAsString 3 character value from ISO 4217.
/// \return The currency code (ECLCurrencyCode). Returns ECLCurrencyCode_Nil if string is nil or length is 0. Returns ECLCurrencyCode_Unknown is unable to match string.
+ (ECLCurrencyCode)currencyCodeFromString:(NSString *)currencyCodeAsString;

/// \brief Returns currency factor for currency code.
///
/// This is the amount to multiple a minor unit value by to get to in major value. For example for USD it is 100.
/// \param code The ECLCurrencyCode value to get currency factor for.
/// \return The currency factor.
+ (long)currencyFactorForCurrencyCode:(ECLCurrencyCode)code;

/// \brief Returns if ECLCurrencyCode is set to a country code and not set to ECLCurrencyCode_Unknown or ECLCurrencyCode_Nil.
/// \param currencyCode ECLCurrencyCode value to check.
/// \return YES if ECLCurrencyCode value for country. NO if ECLCurrencyCode_Unknown or ECLCurrencyCode_Nil.
+ (BOOL)isKnownCurrencyCode:(ECLCurrencyCode)currencyCode;

/// \brief Returns a debug description of the ECLCurrencyCode value which will be the ISO 4217 value if a country.
///
/// Will be "Nil" for ECLCurrencyCode_Nil and "Unknown" for ECLCurrencyCode_Unknown.
/// \param currencyCode ECLCurrencyCode value to return string for.
/// \return The description of the currencyCode.
+ (NSString *)debugDescriptionOfCurrencyCode:(ECLCurrencyCode)currencyCode;

@end