//
//  CacheContainer.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

public protocol CacheContainerable: Sendable {
    func getExchangeRates() async -> [Date : [ExchangeRates]]?
    func setExchangeRates(_ newValue: [Date : [ExchangeRates]]?) async
}

final class CacheContainer: CacheContainerable {
    private let key = "io.kamaal.ForexKit.exchangeRates"

    func getExchangeRates() async -> [Date : [ExchangeRates]]? {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return nil }

        return try? JSONDecoder().decode([Date : [ExchangeRates]].self, from: data)
    }

    func setExchangeRates(_ newValue: [Date : [ExchangeRates]]?) async {
        guard let data = try? JSONEncoder().encode(newValue) else { return }

        UserDefaults.standard.set(data, forKey: key)
    }
}
