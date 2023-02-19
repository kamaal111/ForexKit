//
//  ForexCacheUtilTests.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import XCTest
@testable import ForexKit

final class ForexCacheUtilTests: XCTestCase {
    func testCacheLatestWithInvalidSymbols() async throws {
        let cases: [([Currencies])] = [
            ([]),
            [.EUR]
        ]
        for (symbols) in cases {
            let cacheUtil = ForexCacheUtil(configuration: .init(container: TestCacheContainer()))

            let result = try await cacheUtil.cacheLatest(base: .EUR, symbols: symbols, apiCall: { base, symbols in
                XCTFail("Should be unreachable")
                return .failure(.responseError(message: "Will not come here anyway", code: 420))
            }).get()

            XCTAssertNil(result)
        }

    }

    func testCacheLatestWithNoCache() async throws {
        let cases: [([Date: [ExchangeRates]]?)] = [
            (nil),
            ([:]),
            ([Date(): []]),
            ([Date().addingTimeInterval(-86401): [ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 420])]])
        ]

        for (initialCacheContainerData) in cases {
            let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
            let cacheUtil = ForexCacheUtil(configuration: .init(container: container))
            let expectedResult = ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666])

            var called = false
            let result = await cacheUtil.cacheLatest(base: .EUR, symbols: [.USD], apiCall: { base, symbols in
                called = true
                return .success(expectedResult)
            })

            XCTAssert(called)
            XCTAssertEqual(try result.get(), expectedResult)
            let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
            XCTAssertEqual(cachedExchangeRates.count, 1)
            let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
            XCTAssertEqual(exchangeRates.count, 1)
            let exchangeRate = try XCTUnwrap(exchangeRates.first)
            XCTAssertEqual(exchangeRate, expectedResult)
        }
    }

    func testCacheLatestWithFullCacheFound() async throws {
        let cases: [(Currencies, [Currencies], ExchangeRates)] = [
            (.EUR, [.USD, .CAD], ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666, .CAD: 1.444])),
        ]
        for (base, symbols, expectedResult) in cases {
            let initialCacheContainerData = [Date(): [expectedResult]]
            let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
            let cacheUtil = ForexCacheUtil(configuration: .init(container: container))

            let result = try await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
                XCTFail("Should be unreachable")
                return .failure(.responseError(message: "Will not come here anyway", code: 69))
            }).get()

            let unwrappedResult = try XCTUnwrap(result)
            XCTAssertEqual(unwrappedResult.base, expectedResult.base)
            XCTAssertEqual(unwrappedResult.rates, expectedResult.rates)

            let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
            XCTAssertEqual(cachedExchangeRates.count, 1)
            let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
            XCTAssertEqual(exchangeRates.count, 1)
            let exchangeRate = try XCTUnwrap(exchangeRates.first)
            XCTAssertEqual(exchangeRate, unwrappedResult)
        }
    }

    func testCacheLatestWithConversion() async throws {
        let base: Currencies = .CAD
        let symbols: [Currencies] = [.EUR, .USD]
        let initialCacheContainerData = [Date(): [
            ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 0.6925]),
            ExchangeRates(base: .USD, date: Date(), rates: [.CAD: 1.36]),
        ]]
        let expectedRates: [Currencies: Double] = [.EUR: 1.444, .USD: 0.7353]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(configuration: .init(container: container, ratePointPrecision: 4))

        let result = try await cacheUtil.cacheLatest(base: base, symbols: symbols, apiCall: { base, symbols in
            XCTFail("Should be unreachable")
            return .failure(.responseError(message: "Will not come here anyway", code: 69))
        }).get()

        let unwrappedResult = try XCTUnwrap(result)
        let expectedResult = ExchangeRates(base: base, date: unwrappedResult.date, rates: expectedRates)
        XCTAssertEqual(unwrappedResult.base, expectedResult.base)
        XCTAssertEqual(unwrappedResult.date, expectedResult.date)
        XCTAssertEqual(unwrappedResult.rates.count, expectedResult.rates.count)
        for (currency, amount) in unwrappedResult.ratesMappedByCurrency {
            XCTAssertEqual(amount, expectedResult.ratesMappedByCurrency[currency])
        }

        let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
        XCTAssertEqual(cachedExchangeRates.count, 1)
        let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
        XCTAssertEqual(exchangeRates.count, initialCacheContainerData.first!.value.count + 1)
        let exchangeRate = try XCTUnwrap(exchangeRates.first(where: { $0.base == base.rawValue }))
        XCTAssertEqual(exchangeRate.base, unwrappedResult.base)
        XCTAssertEqual(exchangeRate.date, unwrappedResult.date)
        XCTAssertEqual(exchangeRate.rates.count, unwrappedResult.rates.count)
        for (currency, amount) in exchangeRate.ratesMappedByCurrency {
            XCTAssertEqual(Double(amount.toFixed(4)), unwrappedResult.ratesMappedByCurrency[currency])
        }
    }

    func testCacheLatestWithPartialCacheFound() async throws {
        let initialCacheContainerData = [Date(): [ExchangeRates(base: .EUR, date: Date(), rates: [.CAD: 1.444])]]
        let container = TestCacheContainer(exchangeRates: initialCacheContainerData)
        let cacheUtil = ForexCacheUtil(configuration: .init(container: container))

        var called = false
        let result = try await cacheUtil.cacheLatest(base: .EUR, symbols: [.USD, .CAD], apiCall: { base, symbols in
            called = true
            return .success(ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666]))
        }).get()

        XCTAssert(called)
        let unwrappedResult = try XCTUnwrap(result)
        let expectedResult = ExchangeRates(base: .EUR, date: Date(), rates: [.USD: 1.0666, .CAD: 1.444])
        XCTAssertEqual(unwrappedResult.base, expectedResult.base)
        XCTAssertEqual(unwrappedResult.rates, expectedResult.rates)

        let cachedExchangeRates = try XCTUnwrap(container.exchangeRates)
        XCTAssertEqual(cachedExchangeRates.count, 1)
        let exchangeRates = try XCTUnwrap(cachedExchangeRates.first?.value)
        XCTAssertEqual(exchangeRates.count, 1)
        let exchangeRate = try XCTUnwrap(exchangeRates.first)
        XCTAssertEqual(exchangeRate, unwrappedResult)
    }

    func testCacheLatestWithFailure() async throws {
        let cacheUtil = ForexCacheUtil(configuration: .init(container: TestCacheContainer()))

        let result = await cacheUtil.cacheLatest(base: .EUR, symbols: [.USD, .CAD], apiCall: { base, symbols in
            return .failure(.notAValidJSON)
        })

        XCTAssertEqual(result, .failure(.notAValidJSON))
    }
}
