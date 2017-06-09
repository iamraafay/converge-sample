//
//  ECLMoneyUtil.h
//  CommerceDataTypes
//
//  Copyright © 2016 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommerceDataTypes/ECLMoney.h>

/// \brief Helper class for ECLMoney
/// \copyright (c) 2016 Elavon. All rights reserved.
@interface ECLMoneyUtil : NSObject


/// \brief Perform addition of two monetary amounts as ECLMoney instances.
///
/// NOTE: The currency code of the first addend will be used for the currency code of the sum.
///
/// \param leftMoney Addend monetary amount.
/// \param rightMoney Addend monetary amount.
/// \return Sum as a monetary amount.
+ (ECLMoney *)add:(ECLMoney *)leftMoney andMoney:(ECLMoney*)rightMoney;

/// \brief Perform addition of a monetary amount and an amount in minor units.
///
/// \param leftMoney Addend monetary amount.
/// \param rightMoney Addend amount in minor units.
/// \return Sum as a monetary amount.
+ (ECLMoney *)add:(ECLMoney *)leftMoney andNumber:(NSNumber *)rightMoney;

/// \brief Perform addition of multiple monetary amounts.
///
/// NOTE: The currency code of the first addend will be used for the currency code of the sum.
/// \param leftMoney Variable-sized array of monetary amounts ending in nil argument
/// \return Sum as a monetary amount.
+ (ECLMoney *)addMonies:(ECLMoney *)leftMoney,... NS_REQUIRES_NIL_TERMINATION;

/// \brief Perform subtraction of a two monetary amounts.
///
/// NOTE: The currency code of the first addend will be used for the currency code of the difference.
/// \param leftMoney Minuend monetary amount.
/// \param rightMoney Subtrahend monetary amount.
/// \return Difference as a monetary amount.
+ (ECLMoney *)subtractFrom:(ECLMoney *)leftMoney money:(ECLMoney*)rightMoney;

/// \brief Perform subtraction of a monetary amount and an amount in minor units.
///
/// \param leftMoney Minuend monetary amount.
/// \param rightMoney Subtrahend amount in minor units.
/// \return Difference as a monetary amount.
+ (ECLMoney *)subtractFrom:(ECLMoney *)leftMoney number:(NSNumber *)rightMoney;

/// \brief Perform subtraction of multiple monetary amounts.
///
/// All amounts after leftMoney will be subtracted from leftMoney
/// NOTE: The currency code of the leftMoney will be used for the currency code of the result.
/// \param leftMoney Variable-sized array of monetary amounts ending in nil argument
/// \return Difference as a monetary amount.
+ (ECLMoney *)subtractMoniesFrom:(ECLMoney *)leftMoney,... NS_REQUIRES_NIL_TERMINATION;

/// \brief Create ECLMoney instance using the format specified for currencyCode from string.
///
/// Handles currency symbol in string. For example both "$1.80" and "1.80" for ECLCurrencyCode_USD will be converted to an ECLMoney of 180 with ECLCurrencyCode_USD.
/// \param amount String to be converted
/// \param currencyCode ::ECLCurrencyCode used to determine formatting of string
/// \return ECLMoney instance with value from string.
+ (ECLMoney *)moneyFromString:(NSString *)amount currencyCode:(ECLCurrencyCode)currencyCode;

/// \brief Create string representation of ECLMoney instance.
///
/// \param money ECLMoney instance to be converted to string
/// \param withSymbol if YES the currency symbol will be in the string.
/// \param withSeparators if YES separators will be used such as a thousand seperator.
/// \return NSString representation of the money
+ (NSString *)stringFromMoney:(ECLMoney *)money withSymbol:(BOOL)withSymbol withSeparators:(BOOL)withSeparators;

@end
