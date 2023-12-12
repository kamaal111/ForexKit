//
//  ExchangeRates.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

/// Exchange rates object.
public struct ExchangeRates: Codable, Hashable {
    /// Base currency.
    public let base: String
    /// When the ``ExchangeRates`` has been updated.
    @DateValue<YearMonthDayStrategy> public var date: Date
    /// Rates mapped by currency as key and rate as value.
    public var rates: [String: Double]

    /// Initializer for ``ExchangeRates``.
    /// - Parameters:
    ///   - base: base currency.
    ///   - date: When the ``ExchangeRates`` has been updated.
    ///   - rates: Rates mapped by currency as key and rate as value.
    public init(base: String, date: Date, rates: [String: Double]) {
        self.base = base
        self.date = date
        self.rates = rates
    }

    /// Initializer for ``ExchangeRates``.
    /// - Parameters:
    ///   - base: base currency.
    ///   - date: When the ``ExchangeRates`` has been updated.
    ///   - rates: Rates mapped by ``Currencies`` as key and rate as value.
    public init(base: Currencies, date: Date, rates: [Currencies: Double]) {
        let rates: [String: Double] = rates.reduce([:], {
            var result = $0
            result[$1.key.rawValue] = $1.value
            return result
        })
        self.init(base: base.rawValue, date: date, rates: rates)
    }

    /// Base ``Currencies``.
    public var baseCurrency: Currencies? {
        Currencies(rawValue: base)
    }

    /// Rates mapped by ``Currencies`` as key and rate as value.
    public var ratesMappedByCurrency: [Currencies: Double] {
        rates
            .reduce([:], {
                guard let currency = Currencies(rawValue: $1.key) else { return $0 }

                var result = $0
                result[currency] = $1.value
                return result
            })
    }

    static let preview: ExchangeRates = {
        try! JSONDecoder().decode(ExchangeRates.self, from: previewData.data(using: .utf8)!)
    }()

    private static let previewData: String = """
{
    "base": "EUR",
    "date": "2022-12-30",
    "rates": {
        "AUD": 1.5693,
        "BGN": 1.9558,
        "BRL": 5.6386,
        "CAD": 1.444,
        "CHF": 0.9847,
        "CNY": 7.3582,
        "CZK": 24.116,
        "DKK": 7.4365,
        "GBP": 0.88693,
        "HKD": 8.3163,
        "HRK": 7.5365,
        "HUF": 400.87,
        "IDR": 16519.82,
        "INR": 88.171,
        "ISK": 151.5,
        "JPY": 140.66,
        "KRW": 1344.09,
        "MXN": 20.856,
        "MYR": 4.6984,
        "NOK": 10.5138,
        "NZD": 1.6798,
        "PHP": 59.32,
        "PLN": 4.6808,
        "RON": 4.9495,
        "SEK": 11.1218,
        "SGD": 1.43,
        "THB": 36.835,
        "TRY": 19.9649,
        "USD": 1.0666,
        "ZAR": 18.0986
    }
}
"""
}
