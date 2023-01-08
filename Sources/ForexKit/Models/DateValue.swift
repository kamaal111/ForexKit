//
//  DateValue.swift
//  
//
//  Created by Kamaal M Farah on 08/01/2023.
//

import Foundation

@propertyWrapper
public struct DateValue<Formatter: DateValueCodableStrategy> {
    private let value: Formatter.RawValue
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
        self.value = Formatter.encode(wrappedValue)
    }
}

extension DateValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Formatter.RawValue.self)
        self.wrappedValue = try Formatter.decode(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.encode(wrappedValue))
    }
}

extension DateValue: Equatable {
    public static func == (lhs: DateValue<Formatter>, rhs: DateValue<Formatter>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension DateValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

public struct YearMonthDayStrategy {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter
    }()
}

extension YearMonthDayStrategy: DateValueCodableStrategy {
    public typealias RawValue = String

    public static func decode(_ value: String) throws -> Date {
        guard let date = dateFormatter.date(from: value) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid date format: \(value)"))
        }
        return date
    }

    public static func encode(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}

public protocol DateValueCodableStrategy {
    associatedtype RawValue: Codable
    static func decode(_ value: RawValue) throws -> Date
    static func encode(_ date: Date) -> RawValue
}
