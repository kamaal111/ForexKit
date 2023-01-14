//
//  ForexKitConfiguration.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

public class ForexKitConfiguration {
    let skipCaching: Bool
    let preview: Bool
    let urlSession: URLSession
    var container: CacheContainerable
    let ratePointPrecision: Int

    public init(
        preview: Bool = false,
        skipCaching: Bool = false,
        urlSession: URLSession = .shared,
        container: CacheContainerable? = nil,
        ratePointPrecision: Int = 4) {
            self.skipCaching = skipCaching
            self.preview = preview
            self.urlSession = urlSession
            self.ratePointPrecision = ratePointPrecision
            if let container {
                self.container = container
            } else {
                self.container = CacheContainer()
            }
        }
}
