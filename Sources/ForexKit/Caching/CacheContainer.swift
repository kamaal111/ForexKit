//
//  CacheContainer.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

public protocol CacheContainerable {
    var exchangeRates: [Date : [ExchangeRates]]? { get set }
}

class CacheContainer: CacheContainerable {
    private let key = "io.kamaal.ForexKit.exchangeRates"

    var exchangeRates: [Date : [ExchangeRates]]? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return nil }

            return try? JSONDecoder().decode([Date : [ExchangeRates]].self, from: data)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }

            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
