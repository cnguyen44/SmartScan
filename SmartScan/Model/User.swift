//
//  User.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import Foundation

class User: Codable {
    var userID: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var sessionToken: String?
}
