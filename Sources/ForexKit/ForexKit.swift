//
//  ForexKit.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

public struct ForexKit {
    let cacheUtil: ForexCacheUtil
    let forexAPI: ForexAPI
    let configuration: ForexKitConfiguration

    public init(configuration: ForexKitConfiguration = .init()) {
        self.forexAPI = ForexAPI(configuration: configuration)
        self.cacheUtil = ForexCacheUtil(configuration: configuration)
        self.configuration = configuration
    }

    public func convert(
        from input: (amount: Double, currency: Currencies),
        to base: Currencies,
        withRatesFrom exchangeRates: ExchangeRates,
        reverse: Bool = false) -> (amount: Double, currency: Currencies)? {
            if input.currency == base {
                return input
            }

            if input.amount == 0 {
                return (0, base)
            }

            if reverse {
                let rate = exchangeRates.ratesMappedByCurrency[input.currency]
                if rate == nil {
                    guard let rate = exchangeRates.ratesMappedByCurrency[base] else { return nil }

                    return (input.amount / rate, base)
                }

                guard let rate else { return nil }

                return (input.amount / (1 / rate), base)
            }

            guard let rate = exchangeRates.ratesMappedByCurrency[input.currency] else { return nil }

            return (input.amount * rate, base)
        }

    public func getLatest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates?, Errors> {
        guard !configuration.preview else { return .success(.preview) }

        return await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
            await forexAPI.latest(base: base, symbols: symbols)
        })
        .mapError({ .getExchangeFailure(context: $0) })
    }

    public func getFallback(base: Currencies, symbols: [Currencies]) ->  ExchangeRates? {
        cacheUtil.getFallback(base: base, symbols: symbols)
    }
}

extension ForexKit {
    public enum Errors: Error {
        case getExchangeFailure(context: Error)
    }
}
