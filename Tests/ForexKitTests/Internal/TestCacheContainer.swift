//
//  TestCacheContainer.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
@testable import ForexKit

class TestCacheContainer: CacheContainerable {
    var exchangeRates: [Date: [ExchangeRates]]?

    init(exchangeRates: [Date: [ExchangeRates]]? = nil) {
        self.exchangeRates = exchangeRates
    }
}
