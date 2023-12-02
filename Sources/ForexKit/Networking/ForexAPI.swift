//
//  ForexAPI.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import KamaalNetworker

class ForexAPI: APIClient {
    func latest(base: Currencies, symbols: [Currencies]) async -> Result<ExchangeRates, Errors> {
        guard !configuration.preview else { return .success(.preview) }

        let symbols = symbols.filter({ $0 != base })
        let forexURL = makeForexURL(base: base, symbols: symbols)
        async let forexResponse: Result<ExchangeRates, Errors> = networker.request(from: forexURL)
            .mapError({ .fromKamaalNetworker($0) })
            .map(\.data)

        if base == .BTC || (symbols.contains(.BTC) || symbols.isEmpty) {
            let btcUSDRatesResult = await getBTCUSDRate()
            let btcUSDRates: Double
            switch btcUSDRatesResult {
            case .failure(let failure):
                return .failure(failure)
            case .success(let success):
                btcUSDRates = success
            }

            let forexResponseResult = await forexResponse
            var forexExchangeRates: ExchangeRates
            switch forexResponseResult {
            case .failure(let failure):
                return .failure(failure)
            case .success(let success):
                forexExchangeRates = success
            }

            if base == .BTC {
                var newRates: [Currencies: Double] = [
                    .USD: btcUSDRates
                ]
                for (currency, rate) in forexExchangeRates.ratesMappedByCurrency
                where currency != .BTC && currency != .USD {
                    newRates[currency] = rate / (1 / btcUSDRates)
                }

                return .success(ExchangeRates(base: .BTC, date: Date(), rates: newRates))
            } else {
                guard let usdRates = forexExchangeRates.ratesMappedByCurrency[.USD] else { return forexResponseResult }

                if base == .USD {
                    forexExchangeRates.rates[Currencies.BTC.rawValue] = btcUSDRates
                } else {
                    forexExchangeRates.rates[Currencies.BTC.rawValue] = (1 / usdRates) / (1 / btcUSDRates)
                }

                return .success(forexExchangeRates)
            }
        }

        return await forexResponse
    }

    private var btcURL: URL {
        configuration.btcBaseURL
            .appendingPathComponent("currentprice")
            .appendingPathComponent(Currencies.USD.rawValue)
            .appendingPathExtension("json")
    }

    private func getBTCUSDRate() async -> Result<Double, Errors> {
        let btcResponseResult: Result<BTCCounterPrice, Errors> = await networker.request(from: btcURL)
            .mapError({ .fromKamaalNetworker($0) })
            .map(\.data)
        let btcResponse: BTCCounterPrice
        switch btcResponseResult {
        case .failure(let failure):
            return .failure(failure)
        case .success(let success):
            btcResponse = success
        }

        guard let usdRates = btcResponse.bpi["USD"]?.rateFloat else {
            return .failure(.failedToFetchBTC)
        }

        return .success(usdRates)
    }

    private func makeForexURL(base: Currencies, symbols: [Currencies]) -> URL {
        var forexURLComponents = URLComponents(
            url: configuration.forexBaseURL.appendingPathComponent("latest"),
            resolvingAgainstBaseURL: true)!

        var queryItems: [URLQueryItem] = []
        if base == .BTC {
            queryItems.append(URLQueryItem(name: "base", value: Currencies.USD.rawValue))
        } else {
            assert(!base.isCryptoCurrency, "Unsupported currency")
            queryItems.append(URLQueryItem(name: "base", value: base.rawValue))
        }
        let symbols = symbols
            .filter({ !$0.isCryptoCurrency })
            .map(\.rawValue)
        if !symbols.isEmpty {
            queryItems.append(URLQueryItem(name: "symbols", value: symbols.joined(separator: ",")))
        }
        forexURLComponents.queryItems = queryItems

        return forexURLComponents.url!
    }
}
