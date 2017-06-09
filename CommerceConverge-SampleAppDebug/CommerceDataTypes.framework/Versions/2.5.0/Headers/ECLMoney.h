//
//  ECLMoney.h
//  CommerceDataTypes
//
//  Copyright © 2016 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommerceDataTypes/ECLCurrencyCode.h>

/// \brief Representation of monetary amounts with a currency code (ECLCurrencyCode - ISO 4217) and a value in minor units.
///
/// $10.95 USD would be specified as a minor units value of 1095 and a currency code of ECLCurrencyCode_USD.
///
/// $0.10 USD would be specified as a minor units value of 10 and a currency code of ECLCurrencyCode_USD.
///
/// $0.00 USD would be specified as a minor units value of 0 and a currency code of ECLCurrencyCode_USD.
/// \copyright (c) 2016 Elavon. All rights reserved.
@interface ECLMoney : NSObject

/// \brief Constructor for defining monetary amounts.
/// \param amount Amount in minor units.
/// \param currencyCode Currency code as an value of ECLCurrencyCode
/// \return new instance of ECLMoney
- (id)initWithMinorUnits:(long)amount withCurrencyCode:(ECLCurrencyCode)currencyCode;

/// \brief Helper method that compares minor units and currency code.
/// \param money ECLMoney instance to compare
/// \return YES if values are equal. NO if unequal.
- (BOOL)isEqual:(ECLMoney *)money;

/// \brief Helper method that returns if the minor units is greater than 0
/// \return YES if minor unit value is greater than 0. NO if less than or equal to 0.
- (BOOL)isGreaterThanZero;

/// \brief Property that is the minor unit value
/// \return Minor unit value
@property (readonly)long amount;

/// \brief Property that is the currency code
/// \return Currency code
@property (readonly)ECLCurrencyCode currencyCode;

@end
