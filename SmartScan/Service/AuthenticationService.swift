//
//  AuthenticationService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/22/24.
//

import Foundation

enum AuthenticationError: Error {
    case invalidCredentials
    case invalidState
    case accountNotVerify
}
typealias AuthenticationCompletionHandler = (Result<(User), AuthenticationError>) -> Void

class AuthenticationService{
    static let usernameIdentifier = "com.cnguyen.SmartScan.username"
    static let passwordIdentifier = "com.cnguyen.SmartScan.password"
    
    func signin(username: String, password: String, handler: @escaping AuthenticationCompletionHandler){
        
        let apiClient = MockAPIClient()
        let request = GetUserRequest(username: "", password: "")
        apiClient.send(request) { response in
            print(response)
            switch response{
            case .success(let response):
                //Store username and password to keychain
                let data = KeychainWrapper.keychainStringFromMatchingIdentifier(identifier: AuthenticationService.usernameIdentifier)
                if data == nil {
                    let saveUsernameStatus = KeychainWrapper.createKeychainValue(value: username, forIdentifier: AuthenticationService.usernameIdentifier)
                    let savePasswordStatus = KeychainWrapper.createKeychainValue(value: password, forIdentifier: AuthenticationService.passwordIdentifier)
                    print("Save to keychain username \(saveUsernameStatus) password \(savePasswordStatus)")
                }
                
                //Handle response
                handler(.success(response.user))
            case .failure (let error):
                print(error)
                handler(.failure(.invalidCredentials))
            }
        }
        
    }
    
    func signin(handler: @escaping AuthenticationCompletionHandler){
        let username = KeychainWrapper.keychainStringFromMatchingIdentifier(identifier: AuthenticationService.usernameIdentifier)
        let password = KeychainWrapper.keychainStringFromMatchingIdentifier(identifier: AuthenticationService.passwordIdentifier)
        
        guard let username = username, let password = password else{
            return
        }
        self.signin(username: username, password: password, handler: handler)
    }
    
    func signout(handler: @escaping (Bool)->Void){
        let deleteUsernameStatus = KeychainWrapper.deleteItemFromKeychainWithIdentifier(identifier: AuthenticationService.usernameIdentifier)
        let deletePasswordStatus = KeychainWrapper.deleteItemFromKeychainWithIdentifier(identifier: AuthenticationService.passwordIdentifier)
        
        handler(deleteUsernameStatus && deletePasswordStatus)
    }
}
