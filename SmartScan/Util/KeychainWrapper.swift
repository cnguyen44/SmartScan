//
//  KeychainWrapper.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//
//  Sample codes from Apple

import UIKit
import Security

public class KeychainWrapper: NSObject {

    static let appName = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String]
    
    public class func setupSearchDirectoryForIdentifier(identifier:String)->Dictionary<String,Any>{
        var searchDictionary = Dictionary<String,Any>()
        // Specify we are using a Password (vs Certificate, Internet Password, etc)
        searchDictionary[kSecClass as String]  = kSecClassGenericPassword
        // Uniquely identify this keychain accesser
        searchDictionary[kSecAttrService as String] = KeychainWrapper.appName
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier = identifier.data(using: .utf8)
        searchDictionary[kSecAttrGeneric as String] = encodedIdentifier
        searchDictionary[kSecAttrAccount as String] = encodedIdentifier
        
        return searchDictionary
    }
    
    //Generic exposed method to search the keychain for a given value.  Limit one result per search.
    public class func searchKeychainCopyMatchingIdentifier(identifier:String)->Data?{
        //Setup dictionary
        var searchDictionary = KeychainWrapper.setupSearchDirectoryForIdentifier(identifier: identifier)
        searchDictionary[kSecMatchLimit as String] = kSecMatchLimitOne
        searchDictionary[kSecReturnData as String] = kCFBooleanTrue
        
        //Search
        var result:AnyObject?
        
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(searchDictionary as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found
        guard status != errSecItemNotFound else {
            print(#file, #line, "errSecItemNotFound")
            return nil
        }
        guard status == noErr else {
            return nil
        }
        guard let resultData = result as? Data else{
            print(#file, #line, "unexpectedItemData")
            return nil
        }
        return resultData
    }
    
    //Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
    public class func keychainStringFromMatchingIdentifier(identifier:String)->String?{
        guard let resultData = KeychainWrapper.searchKeychainCopyMatchingIdentifier(identifier: identifier) else{
            return nil
        }
        return String(data: resultData, encoding: .utf8)
    }
    
    // Default initializer to store a value in the keychain.
    // Associated properties are handled for you (setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
    public class func createKeychainValue(value:String,forIdentifier:String)->Bool{
        //Setup dictionary
        var dictionary = KeychainWrapper.setupSearchDirectoryForIdentifier(identifier: forIdentifier)
        guard let valueData = value.data(using: .utf8) else {return false}
        dictionary[kSecValueData as String] = valueData
        dictionary[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        
        //Add
        let status = SecItemAdd(dictionary as CFDictionary, nil)
        if status == errSecSuccess{return true}
        return false
    }
    
    // Updates a value in the keychain.  If you try to set the value with createKeychainValue: and it already exists
    // this method is called instead to update the value in place.
    public class func updateKeychainValue(value:String,forIdentifier:String)->Bool{
        //Setup dictionary
        let searchDictionary = KeychainWrapper.setupSearchDirectoryForIdentifier(identifier: forIdentifier)
        var updateDictionary = KeychainWrapper.setupSearchDirectoryForIdentifier(identifier: forIdentifier)
        guard let valueData = value.data(using: .utf8) else {return false}
        updateDictionary[kSecValueData as String] = valueData
        
        //Update
        let status = SecItemUpdate(searchDictionary as CFDictionary, updateDictionary as CFDictionary)
        if status == errSecSuccess{return true}
        return false
    }
    
    // Delete a value in the keychain
    public class func deleteItemFromKeychainWithIdentifier(identifier:String)->Bool{
        let searchDictionary = KeychainWrapper.setupSearchDirectoryForIdentifier(identifier: identifier)
        let status = SecItemDelete(searchDictionary as CFDictionary)
        if status == errSecSuccess{return true}
        return false
    }
    
    //Generates an SHA256 (much more secure than MD5) Hash
    public class func computeSHA256DigestForData(data:Data)->String?{
        /*
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return  digestData.map { String(format: "%02hhx", $0) }.joined()
         */
        return nil
    }
}
