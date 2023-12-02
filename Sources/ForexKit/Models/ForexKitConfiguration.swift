//
//  ForexKitConfiguration.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import KamaalExtensions

public class ForexKitConfiguration {
    let skipCaching: Bool
    let preview: Bool
    let urlSession: URLSession
    var container: CacheContainerable
    let ratePointPrecision: Int
    let forexBaseURL: URL
    let btcBaseURL: URL

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
