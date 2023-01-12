//
//  Currencies.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import ShrimpExtensions

public enum Currencies: String, CaseIterable, Codable, Hashable, Identifiable {
    case EUR
    case USD
    case CAD
    case TRY

    public var symbol: String {
        switch self {
        case .EUR:
            return "€"
        case .USD:
            return "US$"
        case .CAD:
            return "CA$"
        case .TRY:
            return "₺"
        }
    }

    public var id: UUID {
        switch self {
        case .EUR:
            return UUID(uuidString: "7d1c7187-ce12-4e68-83f4-48c0e0290286")!
        case .USD:
            return UUID(uuidString: "ce009f7f-56b2-4dcf-9166-9b0040f12374")!
        case .CAD:
            return UUID(uuidString: "159a21a1-ac56-4ce5-9022-ea5e6bc0ab16")!
        case .TRY:
            return UUID(uuidString: "6ff2d600-f365-413c-b619-a006277a8f41")!
        }
    }

    public static func findBySymbol(_ symbol: String) -> Currencies? {
        Currencies.allCases.find(by: \.symbol, is: symbol)
    }
}
