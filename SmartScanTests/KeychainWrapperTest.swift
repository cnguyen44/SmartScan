//
//  KeychainWrapperTest.swift
//  SmartScanTests
//
//  Created by Chien Nguyen on 3/23/24.
//

import XCTest
@testable import SmartScan

final class KeychainWrapperTest: XCTestCase {

    static let identifier = "com.cnguyen.SmartScan"
    static let value = "test keychain value"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreateKeychainValue(){
        let status = KeychainWrapper.createKeychainValue(value: KeychainWrapperTest.value, forIdentifier: KeychainWrapperTest.identifier)
        XCTAssertTrue(status)
    }
    
    
    func testKeychainStringFromMatchingIdentifier(){
        let result = KeychainWrapper.keychainStringFromMatchingIdentifier(identifier: KeychainWrapperTest.identifier)
        print(#function, result ?? "no result")
        XCTAssertEqual(result, KeychainWrapperTest.value)
    }
    
    func testUpdateKeychainValue(){
        let status = KeychainWrapper.updateKeychainValue(value: KeychainWrapperTest.value, forIdentifier: KeychainWrapperTest.identifier)
        XCTAssertTrue(status)
    }
    
    func testDeleteItemFromKeychainWithIdentifier(){
        let status = KeychainWrapper.deleteItemFromKeychainWithIdentifier(identifier: KeychainWrapperTest.identifier)
        XCTAssertTrue(status)
    }
    
    func testComputeSHA256DigestForData(){
        guard let data = KeychainWrapper.searchKeychainCopyMatchingIdentifier(identifier: KeychainWrapperTest.identifier) else {
            XCTFail("Data is nil")
            return
        }
        let digestData = KeychainWrapper.computeSHA256DigestForData(data: data)
        XCTAssertNotNil(digestData)
        print(digestData ?? "Data is nil")
    }
    

}
