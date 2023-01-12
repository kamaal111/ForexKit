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
    case AUD
    case BGN
    case BRL
    case CHF
    case CNY
    case JPY
    case CZK

    public var localized: String {
        switch self {
        case .EUR:
            return NSLocalizedString("Euro", comment: "")
        case .USD:
            return NSLocalizedString("US Dollar", comment: "")
        case .CAD:
            return NSLocalizedString("Canadian Dollar", comment: "")
        case .TRY:
            return NSLocalizedString("Turkish Lira", comment: "")
        case .AUD:
            return NSLocalizedString("Australian Dollar", comment: "")
        case .BGN:
            return NSLocalizedString("Bulgarian Lev", comment: "")
        case .BRL:
            return NSLocalizedString("Brazilian Real", comment: "")
        case .CHF:
            return NSLocalizedString("Swiss Franc", comment: "")
        case .CNY:
            return NSLocalizedString("Chinese Yuan", comment: "")
        case .JPY:
            return NSLocalizedString("Japanese Yen", comment: "")
        case .CZK:
            return NSLocalizedString("Czech Koruna", comment: "")
        }
    }

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
        case .AUD:
            return "AU$"
        case .BGN:
            return "лв"
        case .BRL:
            return "R$"
        case .CHF:
            return "₣"
        case .CNY:
            return "CN¥‎"
        case .JPY:
            return "JP¥‎"
        case .CZK:
            return "Kč"
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
        case .AUD:
            return UUID(uuidString: "70476e14-5c66-436f-9796-31bf5b58abd8")!
        case .BGN:
            return UUID(uuidString: "cd0df907-25c9-4609-8a9e-0c41f8cb6ae1")!
        case .BRL:
            return UUID(uuidString: "a3702c24-6f09-4eda-a536-440d06c8cfaf")!
        case .CHF:
            return UUID(uuidString: "4abc287c-c701-414a-98b7-cf9446a56655")!
        case .CNY:
            return UUID(uuidString: "3f5fe41e-d3d2-4a0e-b6c0-628cb3ff06d2")!
        case .JPY:
            return UUID(uuidString: "3793f0b8-4f93-4199-a20e-b4975b5367c2")!
        case .CZK:
            return UUID(uuidString: "7a6a8484-3200-4033-ae05-e1b947c4410c")!
        }
    }
}
