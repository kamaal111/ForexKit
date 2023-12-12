//
//  ForexKit.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

/// A utility object used to fetch and convert currencies.
public struct ForexKit {
    /// configuration for ``ForexKit/ForexKit``.
    public let configuration: ForexKitConfiguration
    let cacheUtil: ForexCacheUtil
    let forexAPI: ForexAPI

    /// Initializer for ``ForexKit/ForexKit``.
    /// - Parameter configuration: configuration for ``ForexKit/ForexKit``.
    public init(configuration: ForexKitConfiguration = .init()) {
        self.forexAPI = ForexAPI(configuration: configuration)
        self.cacheUtil = ForexCacheUtil(configuration: configuration)
        self.configuration = configuration
    }

    /// Method to convert 1 base ``Currencies`` with amount to another.
    /// - Parameters:
    ///   - input: Amount and ``Currencies`` to convert from.
    ///   - currencyToConvertTo: The new ``Currencies`` to convert to.
    ///   - withRatesFrom: The ``ExchangeRates`` to use for the convertion.
    ///   - reverse: Whether to reverse conversion.
    /// - Returns: The converted rate and the converted currency.
    public func convert(
        from input: (amount: Double, currency: Currencies),
        to currencyToConvertTo: Currencies,
        withRatesFrom exchangeRates: ExchangeRates,
        reverse: Bool = false) -> (amount: Double, currency: Currencies)? {
            if input.currency == currencyToConvertTo {
                return input
            }

            if input.amount == 0 {
                return (0, currencyToConvertTo)
            }

            guard let rate = exchangeRates.ratesMappedByCurrency[input.currency] else {
                return nil
            }

            var amount = input.amount
            if reverse {
                amount /= rate
            } else {
                amount *= rate
            }
            return (amount, currencyToConvertTo)
        }

    /// Get latest ``ExchangeRates``.
    ///
    /// This call cached and can be configured by initializing ``ForexKit/ForexKit`` with a custom ``ForexKitConfiguration``.
    /// - Parameters:
    ///   - base: ``Currencies``  to base the ``ExchangeRates`` on.
    ///   - symbols: The ``Currencies``s to get extchange rates for.
    /// - Returns: A result of either ``ExchangeRates`` on success or ``Errors`` on failure.
    public func getLatest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates?, Errors> {
        guard !configuration.preview else { return .success(.preview) }

        return await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
            await forexAPI.latest(base: base, symbols: symbols)
        })
        .mapError({ .getExchangeFailure(context: $0) })
    }

    /// Get latest cached ``ExchangeRates``.
    /// - Parameters:
    ///   - base: ``Currencies``  to base the ``ExchangeRates`` on.
    ///   - symbols: The ``Currencies``s to get extchange rates for.
    /// - Returns: ``ExchangeRates`` on success or `nil` when no fallback can be found.
    public func getFallback(base: Currencies, symbols: [Currencies]) ->  ExchangeRates? {
        cacheUtil.getFallback(base: base, symbols: symbols)
    }
}

extension ForexKit {
    /// ``ForexKit`` errors.
    public enum Errors: Error {
        /// Failed to fetch ``ExchangeRates``.
        case getExchangeFailure(context: Error)
    }
}
