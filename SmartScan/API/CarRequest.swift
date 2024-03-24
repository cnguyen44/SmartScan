//
//  CarRequest.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation

struct GetCarResponse: Codable {
    var count: Int
    var results: [Car]?
    
    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case results = "Results"
    }
}

class GetCarRequest: APIRequest{
    var method = HTTPMethod.get
    var path = "/api/vehicles/decodevinvalues/"
    var parameters = [String: String]()
    var httpHeader = ["Content-Type": "application/json"]
    var httpBody: Data?
    
    public typealias Response = GetCarResponse
    
    init(vin: String){
        self.path += "/" + vin
        self.parameters["format"] = "json"
    }
}
