//
//  ForexKitTests.swift
//
//
//  Created by Kamaal M Farah on 08/01/2023.
//


import XCTest
import MockURLProtocol
import ShrimpExtensions
@testable import ForexKit

final class ForexKitTests: XCTestCase {
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()

    // - MARK: Convert

    func testReverseConvert() throws {
        let rates = try JSONDecoder().decode(ExchangeRates.self, from: successForexResponse.data(using: .utf8)!)

        let cases: [((amount: Double, currency: Currencies), Currencies, (amount: Double, currency: Currencies))] = [
            ((420, .USD), .EUR, (393.7746, .EUR))
        ]

        for (input, preferedCurrency, expectedResult) in cases {
            let maybeResult = ForexKit().convert(from: input, to: preferedCurrency, withRatesFrom: rates, reverse: true)
            let result = try XCTUnwrap(maybeResult)
            XCTAssertEqual(Double(result.amount.toFixed(4)), expectedResult.amount)
            XCTAssertEqual(result.currency, expectedResult.currency)
        }
    }

    func testConvert() throws {
        let rates = try JSONDecoder().decode(ExchangeRates.self, from: successForexResponse.data(using: .utf8)!)

        let cases: [((amount: Double, currency: Currencies), Currencies, (amount: Double, currency: Currencies))] = [
            ((420, .EUR), .EUR, (420, .EUR)),
            ((69, .USD), .EUR, (73.5954, .EUR)),
            ((0, .EUR), .CAD, (0, .CAD)),
        ]

        for (input, preferedCurrency, expectedResult) in cases {
            let maybeResult = ForexKit().convert(from: input, to: preferedCurrency, withRatesFrom: rates)
            let result = try XCTUnwrap(maybeResult)
            XCTAssertEqual(result.amount, expectedResult.amount)
            XCTAssertEqual(result.currency, expectedResult.currency)
        }
    }

    func testConvertWithBitcoinBase() throws {
        let rates = ExchangeRates(base: .BTC, date: Date(), rates: [.EUR: 0.00004363121673937809])

        let cases: [((amount: Double, currency: Currencies), Currencies, (amount: Double, currency: Currencies))] = [
            ((22_919.37, .EUR), .BTC, (1, .BTC))
        ]

        for (input, preferedCurrency, expectedResult) in cases {
            let maybeResult = ForexKit().convert(from: input, to: preferedCurrency, withRatesFrom: rates)
            let result = try XCTUnwrap(maybeResult)
            XCTAssertEqual(result.amount, expectedResult.amount)
            XCTAssertEqual(result.currency, expectedResult.currency)
        }
    }

    func testConvertWithUndefinedRate() throws {
        let rawResponse = """
{
    "base": "EUR",
    "date": "2022-12-30",
    "rates": {
        "CAD": 1.444,
        "GBP": 0.88693,
        "JPY": 140.66,
        "TRY": 19.9649
    }
}
""".data(using: .utf8)!
        let rates = try JSONDecoder().decode(ExchangeRates.self, from: rawResponse)

        let result = ForexKit().convert(from: (69, .USD), to: .EUR, withRatesFrom: rates)

        XCTAssertNil(result)
    }

    // - MARK: Get fallback

    func testGetFallbackFromCompleteEntryWithSameBase() throws {
        let expectedResult = ExchangeRates(base: .CAD, date: Date(), rates: [.EUR: 420, .USD: 69])
        let initialCacheContainerData = [Date(): [expectedResult]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = try XCTUnwrap(forexKit.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.base, expectedResult.base)
        XCTAssertEqual(result.rates, expectedResult.rates)
    }

    func testGetFallbackFromPartialyCompleteEntryWithSameBase() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .CAD, date: Date(), rates: [.EUR: 420]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 2]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = try XCTUnwrap(forexKit.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.baseCurrency, .CAD)
        XCTAssertEqual(result.ratesMappedByCurrency, [.EUR: 420, .USD: 0.5])
    }

    func testGetFallbackFromNonBaseEntry() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 0.5]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 2]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = try XCTUnwrap(forexKit.getFallback(base: .CAD, symbols: [.EUR, .USD]))
        XCTAssertEqual(result.baseCurrency, .CAD)
        XCTAssertEqual(result.ratesMappedByCurrency, [.EUR: 2, .USD: 0.5])
    }

    func testGetFallbackNotFound() throws {
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 0.5]),
        ]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = forexKit.getFallback(base: .EUR, symbols: [.CAD])

        XCTAssertNil(result)
    }

    func testGetFallbackWithInvalidSymbols() {
        let cases: [(Currencies, [Currencies])] = [
            (.CAD, []),
            (.CAD, [.CAD]),
        ]

        let initialCacheContainerData = [Date(): [ExchangeRates(base: .CAD, date: Date(), rates: [.EUR: 420, .USD: 69])]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)
        for (base, symbols) in cases {
            let result = forexKit.getFallback(base: base, symbols: symbols)
            XCTAssertNil(result)
        }
    }

    func testGetFallbackWithNoCache() {
        let container = TestCacheContainer(exchangeRates: nil)
        let configuration = ForexKitConfiguration(container: container)
        let forexKit = ForexKit(configuration: configuration)
        XCTAssertNil(forexKit.getFallback(base: .EUR, symbols: [.CAD]))
    }

    // - MARK: Get latest

    func testGetLatestWithoutCache() async throws {
        makeResponses(with: [
            ResponseBody(host: .forex, body: successForexResponse),
            ResponseBody(host: .bitcoin, body: successBTCResponse)
        ], status: 200)
        let container = TestCacheContainer(exchangeRates: nil)
        let configuration = ForexKitConfiguration(
            preview: false,
            skipCaching: true,
            urlSession: urlSession,
            container: container)
        let forexKit = ForexKit(configuration: configuration)

        let maybeResult = try await forexKit.getLatest(base: .EUR, symbols: [.CAD, .USD, .BTC]).get()

        let result = try XCTUnwrap(maybeResult)
        XCTAssertEqual(result.baseCurrency, .EUR)
        let dateComponents = Calendar.current.dateComponents([.day, .year, .month], from: result.date)
        XCTAssertEqual(dateComponents.day, 30)
        XCTAssertEqual(dateComponents.month, 12)
        XCTAssertEqual(dateComponents.year, 2022)
        XCTAssertNil(container.exchangeRates)
        XCTAssertEqual(Double(result.ratesMappedByCurrency[.BTC]?.toFixed(4) ?? ""), 21367.9752)
    }

    func testGetLatestFailure() async throws {
        let message = """
{
    "message": "Oh nooo!"
}
"""
        makeResponses(with: [ResponseBody(host: .forex, body: message)], status: 400)
        let container = TestCacheContainer(exchangeRates: nil)
        let configuration = ForexKitConfiguration(
            preview: false,
            skipCaching: true,
            urlSession: urlSession,
            container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = await forexKit.getLatest(base: .EUR, symbols: [.USD, .CAD])

        XCTAssertThrowsError(try result.get())
        XCTAssertNil(container.exchangeRates)
    }

    func testGetLatestPreview() async throws {
        let container = TestCacheContainer(exchangeRates: nil)
        let configuration = ForexKitConfiguration(
            preview: true,
            skipCaching: false,
            urlSession: urlSession,
            container: container)
        let forexKit = ForexKit(configuration: configuration)

        let result = try await forexKit.getLatest(base: .EUR, symbols: [.USD, .CAD]).get()

        XCTAssertEqual(result, .preview)
        XCTAssertNil(container.exchangeRates)
    }

    func makeResponses(with responseBodies: [ResponseBody], status: Int) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string: "https://kamaal.io")!,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!

            let data = responseBodies
                .first(where: { $0.host.rawValue == request.url!.host })!
                .body
                .data(using: .utf8)!
            return (response, data)
        }
    }

    struct ResponseBody {
        let host: Hosts
        let body: String

        enum Hosts: String {
            case forex = "theforexapi.com"
            case bitcoin = "api.coindesk.com"
        }
    }
}

private let successBTCResponse = """
{
    "bpi": {
        "USD": {
            "code": "USD",
            "description": "United States Dollar",
            "rate": "22,791.0824",
            "rate_float": 22791.0824
        }
    },
    "disclaimer": "This data was produced from the CoinDesk Bitcoin Price Index (USD). Non-USD currency data converted using hourly conversion rate from openexchangerates.org",
    "time": {
        "updated": "Jan 22, 2023 16:02:00 UTC",
        "updatedISO": "2023-01-22T16:02:00+00:00",
        "updateduk": "Jan 22, 2023 at 16:02 GMT"
    }
}
"""

private let successForexResponse = """
{
    "base": "EUR",
    "date": "2022-12-30",
    "rates": {
        "CAD": 1.444,
        "GBP": 0.88693,
        "JPY": 140.66,
        "TRY": 19.9649,
        "USD": 1.0666
    }
}
"""
