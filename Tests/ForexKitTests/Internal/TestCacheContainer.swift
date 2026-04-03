//
//  TestCacheContainer.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
@testable import ForexKit

actor TestCacheContainer: CacheContainerable {
    var exchangeRates: [Date: [ExchangeRates]]?

    init(exchangeRates: [Date: [ExchangeRates]]? = nil) {
        self.exchangeRates = exchangeRates
    }

    func getExchangeRates() -> [Date: [ExchangeRates]]? {
        exchangeRates
    }

    func setExchangeRates(_ newValue: [Date: [ExchangeRates]]?) {
        exchangeRates = newValue
    }
}
