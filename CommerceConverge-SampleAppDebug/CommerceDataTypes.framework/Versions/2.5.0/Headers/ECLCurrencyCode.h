//
//  ECLCurrencyCode.h
//  CommerceDataTypes
//
//  Copyright © 2016 Elavon Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// \brief Enum of country currency codes (ISO 4217).
/// ECLCurrencyCode_Nil is unset value. ECLCurrencyCode_Unknown is unmatched value.
/// \copyright (c) 2016 Elavon. All rights reserved.
typedef enum
{
    ECLCurrencyCode_Nil = 0,
    ECLCurrencyCode_Unknown,
    ECLCurrencyCode_CAD,
    ECLCurrencyCode_EUR,
    ECLCurrencyCode_GBP,
    ECLCurrencyCode_PLN,
    ECLCurrencyCode_USD,
} ECLCurrencyCode;