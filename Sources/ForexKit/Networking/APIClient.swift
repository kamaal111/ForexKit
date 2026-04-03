//
//  APIClient.swift
//  
//
//  Created by Kamaal M Farah on 22/01/2023.
//

import Foundation
import KamaalNetworker

protocol APIClient {
    var networker: KamaalNetworker { get }
    var configuration: ForexKitConfiguration { get }
}
