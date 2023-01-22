//
//  APIClient.swift
//  
//
//  Created by Kamaal M Farah on 22/01/2023.
//

import Foundation
import XiphiasNet

class APIClient {
    let networker: XiphiasNet
    let configuration: ForexKitConfiguration

    init(configuration: ForexKitConfiguration) {
        self.networker = XiphiasNet(urlSession: configuration.urlSession)
        self.configuration = configuration
    }

    enum Errors: Error, Equatable {
        case generalError(context: Error)
        case responseError(message: String, code: Int)
        case notAValidJSON
        case parsingError(context: Error)
        case invalidURL(url: String)
        case failedToFetchBTC

        static func == (lhs: Errors, rhs: Errors) -> Bool {
            lhs.stringified == rhs.stringified
        }

        static func fromXiphiasNet(_ error: XiphiasNet.Errors) -> Errors {
            switch error {
            case .generalError:
                return .generalError(context: error)
            case .responseError(message: let message, code: let code):
                return .responseError(message: message, code: code)
            case .notAValidJSON:
                return .notAValidJSON
            case .parsingError:
                return .parsingError(context: error)
            case .invalidURL(url: let url):
                return .invalidURL(url: url)
            }
        }

        fileprivate var stringified: String {
            switch self {
            case .generalError(context: let context):
                return "general_error_\(context)"
            case .responseError(message: let message, code: let code):
                return "response_error_\(message)_\(code)"
            case .notAValidJSON:
                return "not_valid_json"
            case .parsingError(context: let context):
                return "parsing_error_\(context)"
            case .invalidURL(url: let url):
                return "invalid_url_\(url)"
            case .failedToFetchBTC:
                return "failed_to_fetch_btc"
            }
        }
    }
}
