//
//  ForexCacheUtil.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import ShrimpExtensions

class ForexCacheUtil {
    let configuration: ForexKitConfiguration

    init(configuration: ForexKitConfiguration) {
        self.configuration = configuration
    }

    func cacheLatest(
        base: Currencies,
        symbols: [Currencies],
        apiCall: (_ base: Currencies, _ symbols: [Currencies]) async -> Result<ExchangeRates, ForexAPI.Errors>) async -> Result<ExchangeRates?, ForexAPI.Errors> {
            let symbols = symbols.filter({ $0 != base })
            guard !symbols.isEmpty else { return .success(nil) }

            if configuration.skipCaching {
                return await apiCall(base, symbols)
                    .map({ success -> ExchangeRates? in
                        success
                    })
            }

            let cacheKey = Date().hashed
            var foundCachedRates: [Currencies: Double] = [:]
            var remainingSymbols = symbols
            let cachedExchangeRates = configuration.container.exchangeRates?
                .find(by: \.key.hashed, is: cacheKey)?
                .value
            if let cachedExchangeRates {
                foundCachedRates = getCachedResultForLatest(
                    cachedExchangeRates: cachedExchangeRates,
                    base: base,
                    symbols: symbols)
                let foundCachedRatesSymbols = foundCachedRates
                    .map(\.key)
                    .sorted(by: \.rawValue, using: .orderedAscending)
                if foundCachedRatesSymbols == symbols.sorted(by: \.rawValue, using: .orderedAscending) {
                    let completeExchangeRates = ExchangeRates(base: base, date: cacheKey, rates: foundCachedRates)
                    var groupedExchangeRatesByBase = Dictionary(
                        grouping: cachedExchangeRates.filter({ $0.baseCurrency != nil }),
                        by: \.baseCurrency!)
                        .reduce([:] as [Currencies: ExchangeRates], {
                            var result = $0
                            if let rate = $1.value.first {
                                result[$1.key] = rate
                            }
                            return result
                        })
                    groupedExchangeRatesByBase[base] = completeExchangeRates
                    configuration.container.exchangeRates = [cacheKey: groupedExchangeRatesByBase.values.asArray()]

                    return .success(completeExchangeRates)
                } else {
                    var newRemainingSymbols: [Currencies] = []
                    for symbol in symbols where !foundCachedRatesSymbols.contains(symbol) {
                        newRemainingSymbols = newRemainingSymbols.appended(symbol)
                    }
                    remainingSymbols = newRemainingSymbols
                }
            }

            assert(!remainingSymbols.isEmpty, "Remaining symbols should not be empty!")

            let result = await apiCall(base, remainingSymbols)
                .map({
                    ExchangeRates(
                        base: base,
                        date: $0.date,
                        rates: $0.ratesMappedByCurrency.merged(with: foundCachedRates))
                })

            let completeExchangeRates: ExchangeRates
            switch result {
            case .failure(let failure):
                return .failure(failure)
            case .success(let success):
                completeExchangeRates = success
            }

            var groupedExchangeRatesByBase = Dictionary(
                grouping: cachedExchangeRates?.filter({ $0.baseCurrency != nil }) ?? [],
                by: \.baseCurrency!)
                .reduce([:] as [Currencies: ExchangeRates], {
                    var result = $0
                    if let rate = $1.value.first {
                        result[$1.key] = rate
                    }
                    return result
                })
            groupedExchangeRatesByBase[base] = completeExchangeRates
            configuration.container.exchangeRates = [cacheKey: groupedExchangeRatesByBase.values.asArray()]

            return .success(completeExchangeRates)
        }

    func getFallback(base: Currencies, symbols: [Currencies]) -> ExchangeRates? {
        guard let cachedExchangeRates = configuration.container.exchangeRates else { return nil }

        let symbols = symbols
            .filter({ $0 != base })
            .sorted(by: \.rawValue, using: .orderedAscending)
        guard !symbols.isEmpty else { return nil }

        let sortedKeys = cachedExchangeRates
            .keys
            .sorted(by: { $0.compare($1) == .orderedDescending })

        for key in sortedKeys {
            let exchangeRates = cachedExchangeRates[key]!
            let rates = getCachedResultForLatest(cachedExchangeRates: exchangeRates, base: base, symbols: symbols)
            let sortedRatesSymbols = rates
                .keys
                .sorted(by: \.rawValue, using: .orderedAscending)
            if sortedRatesSymbols == symbols {
                return ExchangeRates(base: base, date: key, rates: rates)
            }
        }

        return nil
    }

    private func getCachedResultForLatest(
        cachedExchangeRates: [ExchangeRates],
        base: Currencies,
        symbols: [Currencies]) -> [Currencies: Double] {
            cachedExchangeRates.reduce([:], { result, exchangeRate in
                guard let exchangeRateBase = exchangeRate.baseCurrency else {
                    assertionFailure("Unsupported currency \(exchangeRate.base)")
                    return result
                }

                let ratesMappedByCurrency = exchangeRate.ratesMappedByCurrency
                var result = result
                if exchangeRateBase == base {
                    symbols.forEach({ symbol in
                        guard let rate = ratesMappedByCurrency[symbol] else { return }

                        result[symbol] = rate
                    })

                    return result
                }

                guard let symbol = symbols.first(where: { $0 == exchangeRateBase }),
                      let rate = ratesMappedByCurrency[base] else { return result }

                result[symbol] = Double((1 / rate).toFixed(configuration.ratePointPrecision))
                return result
            })
        }
}

extension Date {
    fileprivate var hashed: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: self)
        guard let hashedDate = Calendar.current.date(from: dateComponents) else {
            assertionFailure("Failed to hash date")
            return Date()
        }

        return hashedDate
    }
}
