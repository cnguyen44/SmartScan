//
//  DataManager.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    //Make init private to stops other parts of our code from trying to create a MySingleton class instance
    private init() { }
    
    let serverEndpoint = "https://smartscan.com"
    let vinEndpoint = "https://vpic.nhtsa.dot.gov"
    let serverVersionAndUserRoute = "/v1/clients"
    
    var user: User?
}

