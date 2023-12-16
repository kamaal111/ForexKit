//
//  Currencies.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation
import KamaalExtensions

/// Enumeration that contains currencies.
public enum Currencies: String, CaseIterable, Codable, Hashable, Identifiable {
    /// Euro
    case EUR
    /// US Dollar
    case USD
    /// Canadian Dollar
    case CAD
    /// Turkish Lira
    case TRY
    /// Australian Dollar
    case AUD
    ///  Bulgarian Lev
    case BGN
    /// Brazilian Real
    case BRL
    /// Swiss Franc
    case CHF
    /// Chinese Yuan
    case CNY
    /// Japanese Yen
    case JPY
    /// Czech Koruna
    case CZK
    /// Danish Krone
    case DKK
    /// British Pound
    case GBP
    /// Hong Kong Dollar
    case HKD
    /// Hungarian Forint
    case HUF
    /// Indonesian Rupiah
    case IDR
    /// Indian Rupee
    case INR
    /// Icelandic Krona
    case ISK
    /// South Korean Won
    case KRW
    /// Mexican Peso
    case MXN
    /// Malaysian Ringgit
    case MYR
    /// Norwegian Krone
    case NOK
    /// New Zealand Dollar
    case NZD
    /// Philippine Peso
    case PHP
    /// Złoty
    case PLN
    /// Romanian Leu
    case RON
    /// Swedish Krona
    case SEK
    /// Singapore Dollar
    case SGD
    /// Thai Baht
    case THB
    /// South African Rand
    case ZAR
    /// Bitcoin
    case BTC

    /// Whether ``Currencies`` is crypto currency or not.
    public var isCryptoCurrency: Bool {
        switch self {
        case .BTC:
            return true
        default:
            return false
        }
    }

    /// Localized string for ``Currencies``.
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
        case .DKK:
            return NSLocalizedString("Danish Krone", comment: "")
        case .GBP:
            return NSLocalizedString("British Pound", comment: "")
        case .HKD:
            return NSLocalizedString("Hong Kong Dollar", comment: "")
        case .HUF:
            return NSLocalizedString("Hungarian Forint", comment: "")
        case .IDR:
            return NSLocalizedString("Indonesian Rupiah", comment: "")
        case .INR:
            return NSLocalizedString("Indian Rupee", comment: "")
        case .ISK:
            return NSLocalizedString("Icelandic Krona", comment: "")
        case .KRW:
            return NSLocalizedString("South Korean Won", comment: "")
        case .MXN:
            return NSLocalizedString("Mexican Peso", comment: "")
        case .MYR:
            return NSLocalizedString("Malaysian Ringgit", comment: "")
        case .NOK:
            return NSLocalizedString("Norwegian Krone", comment: "")
        case .NZD:
            return NSLocalizedString("New Zealand Dollar", comment: "")
        case .PHP:
            return NSLocalizedString("Philippine Peso", comment: "")
        case .PLN:
            return NSLocalizedString("Polish Złoty", comment: "")
        case .RON:
            return NSLocalizedString("Romanian Leu", comment: "")
        case .SEK:
            return NSLocalizedString("Swedish Krona", comment: "")
        case .SGD:
            return NSLocalizedString("Singapore Dollar", comment: "")
        case .THB:
            return NSLocalizedString("Thai Baht", comment: "")
        case .ZAR:
            return NSLocalizedString("South African Rand", comment: "")
        case .BTC:
            return NSLocalizedString("Bitcoin", comment: "")
        }
    }

    /// Symbol for ``Currencies``.
    public var symbol: String {
        switch self {
        case .EUR:
            return "€"
        case .USD, .CAD, .AUD, .BRL, .HKD, .MXN, .NZD, .SGD:
            return "$"
        case .TRY:
            return "₺"
        case .BGN:
            return "лв"
        case .CHF:
            return "₣"
        case .CNY, .JPY:
            return "¥‎"
        case .CZK:
            return "Kč"
        case .GBP:
            return "£"
        case .HUF:
            return "Ft"
        case .IDR:
            return "Rp"
        case .INR:
            return "₹"
        case .ISK, .NOK, .DKK, .SEK:
            return "kr"
        case .KRW:
            return "₩"
        case .MYR:
            return "RM"
        case .PHP:
            return "₱"
        case .PLN:
            return "zł"
        case .RON:
            return "L"
        case .THB:
            return "฿"
        case .ZAR:
            return "R"
        case .BTC:
            return "₿"
        }
    }

    /// Symbol prefix for ``Currencies``.
    public var symbolPrefix: String {
        switch self {
        case .ISK:
            return "Í"
        case .HKD:
            return "HK"
        case .JPY:
            return "JP"
        case .CNY:
            return "CN"
        case .BRL:
            return "R"
        case .AUD:
            return "AU"
        case .CAD:
            return "CA"
        case .USD:
            return "US"
        case .MXN:
            return "Mex"
        case .NZD:
            return "NZ"
        case .NOK:
            return "N"
        case .SGD:
            return "S"
        default:
            return ""
        }
    }

    /// Unique identifier for ``Currencies``.
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
        case .DKK:
            return UUID(uuidString: "1675c7eb-648c-4539-910f-6557415644a2")!
        case .GBP:
            return UUID(uuidString: "314add5c-0f4d-4d49-9088-03a310a1b416")!
        case .HKD:
            return UUID(uuidString: "0efbab1f-0b34-441f-9ad1-0399595fd084")!
        case .HUF:
            return UUID(uuidString: "822d3f41-aee0-4019-9d8c-32a4ce76ca35")!
        case .IDR:
            return UUID(uuidString: "69ea4a5f-aa15-41b7-86af-b84883bcf40e")!
        case .INR:
            return UUID(uuidString: "e79d8ee3-0632-46fd-8cdb-cffb49f6d04b")!
        case .ISK:
            return UUID(uuidString: "26af4cc3-1942-4bf8-b4d3-8f2fc57cc181")!
        case .KRW:
            return UUID(uuidString: "2114b201-4505-43ef-9efe-7bc6b6ede485")!
        case .MXN:
            return UUID(uuidString: "6e80caa5-c911-45c2-9cee-bd490438a168")!
        case .MYR:
            return UUID(uuidString: "ce7658f7-7a76-4b3e-b5b6-a4fff4b630b5")!
        case .NOK:
            return UUID(uuidString: "2e33ed8a-0e69-4400-92c7-b846eef4f573")!
        case .NZD:
            return UUID(uuidString: "3da4da8c-9475-4086-9023-d90cd72a543b")!
        case .PHP:
            return UUID(uuidString: "b4196746-d83f-4f1a-af9f-6f8daf343a6d")!
        case .PLN:
            return UUID(uuidString: "30c51665-26be-4fd3-a3d2-3341848ad37c")!
        case .RON:
            return UUID(uuidString: "10809690-87a4-495e-afaf-73db3cf830f3")!
        case .SEK:
            return UUID(uuidString: "98f2fd45-9b83-4b77-85bd-aca16201a227")!
        case .SGD:
            return UUID(uuidString: "58f3637e-989f-478a-b718-7523dd7fd6db")!
        case .THB:
            return UUID(uuidString: "a72fe535-fb99-4587-b814-2b8d7d49bd31")!
        case .ZAR:
            return UUID(uuidString: "bd449bcc-53b2-458b-9562-51bcd44f11b2")!
        case .BTC:
            return UUID(uuidString: "d2f5fb21-41fa-4128-8be5-7088a6e18504")!
        }
    }
}
