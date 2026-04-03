//
//  ForexAPI.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import KamaalNetworker

final class ForexAPI: APIClient, Sendable {
    let networker: KamaalNetworker
    let configuration: ForexKitConfiguration

    init(configuration: ForexKitConfiguration) {
        self.networker = KamaalNetworker(urlSession: configuration.urlSession)
        self.configuration = configuration
    }

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

    enum Errors: Error, Equatable {
        case generalError(context: Error)
        case responseError(message: String, code: Int)
        case notAValidJSON
        case parsingError(context: Error)
        case invalidURL(url: String)
        case failedToFetchBTC

        static func == (lhs: Errors, rhs: Errors) -> Bool {
            lhs.stringified == rhs.stringified
        }

        static func fromKamaalNetworker(_ error: KamaalNetworker.Errors) -> Errors {
            switch error {
            case .generalError:
                return .generalError(context: error)
            case .responseError(message: let message, code: let code):
                return .responseError(message: message, code: code)
            case .notAValidJSON:
                return .notAValidJSON
            case .parsingError:
                return .parsingError(context: error)
            case .invalidURL(url: let url):
                return .invalidURL(url: url)
            }
        }

        fileprivate var stringified: String {
            switch self {
            case .generalError(context: let context):
                return "general_error_\(context)"
            case .responseError(message: let message, code: let code):
                return "response_error_\(message)_\(code)"
            case .notAValidJSON:
                return "not_valid_json"
            case .parsingError(context: let context):
                return "parsing_error_\(context)"
            case .invalidURL(url: let url):
                return "invalid_url_\(url)"
            case .failedToFetchBTC:
                return "failed_to_fetch_btc"
            }
        }
    }

}
