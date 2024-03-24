//
//  UserRequest.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation

struct GetUserResponse: Codable {
    var user: User
}

class GetUserRequest: APIRequest{
    var method = HTTPMethod.get
    var path = DataManager.shared.serverVersionAndUserRoute
    var parameters = [String: String]()
    var httpHeader = ["Content-Type": "application/json"]
    var httpBody: Data?
    
    public typealias Response = GetUserResponse
    
    init(username: String, password: String){
        let authData = (username + ":" + password).data(using: .utf8)!.base64EncodedString()

        self.parameters["format"] = "json"
        self.httpHeader["Authorization"] = "Basic \(authData)"
    }
}
