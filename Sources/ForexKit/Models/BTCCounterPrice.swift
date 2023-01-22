//
//  BTCCounterPrice.swift
//  
//
//  Created by Kamaal M Farah on 19/02/2023.
//

import Foundation

struct BTCCounterPrice: Codable {
    let bpi: [String: BPI]
    let time: Time

    struct BPI: Codable {
        let code: String
        let description: String
        let rate: String
        let rateFloat: Double

        enum CodingKeys: String, CodingKey {
            case code
            case description
            case rate
            case rateFloat = "rate_float"
        }
    }

    struct Time: Codable {
        let updated: String // Jan 22, 2023 18:17:00 UTC
        let updatedISO: String // 2023-01-22T18:17:00+00:00
        let updateduk: String // Jan 22, 2023 at 18:17 GMT
    }
}
