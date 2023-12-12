//
//  ForexKitConfiguration.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import KamaalExtensions

/// Configuration class for ``ForexKit/ForexKit``.
public class ForexKitConfiguration {
    let skipCaching: Bool
    let preview: Bool
    let urlSession: URLSession
    var container: CacheContainerable
    let ratePointPrecision: Int
    let forexBaseURL: URL
    let btcBaseURL: URL

    /// Initializer for ``ForexKitConfiguration``.
    /// - Parameters:
    ///   - preview: Whether to use preview (fake) data or not.
    ///   - skipCaching: Whether to skip caching or not.
    ///   - urlSession: `URLSession` object for ``ForexKit/ForexKit``.
    ///   - container: Caching container.
    ///   - ratePointPrecision: Point precision for ``ExchangeRates``.
    ///   - forexBaseURL: `URL` to fetch forex exchange rates.
    ///   - btcBaseURL: `URL` to fetch Bitcoin rates.
    public init(
        preview: Bool = false,
        skipCaching: Bool = false,
        urlSession: URLSession = .shared,
        container: CacheContainerable? = nil,
        ratePointPrecision: Int = 4,
        forexBaseURL: URL = URL(staticString: "https://theforexapi.com/api"),
        btcBaseURL: URL = URL(staticString: "https://api.coindesk.com/v1/bpi")) {
            self.skipCaching = skipCaching
            self.preview = preview
            self.urlSession = urlSession
            self.ratePointPrecision = ratePointPrecision
            self.forexBaseURL = forexBaseURL
            self.btcBaseURL = btcBaseURL
            if let container {
                self.container = container
            } else {
                self.container = CacheContainer()
            }
        }
}
