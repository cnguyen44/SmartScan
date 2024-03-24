//
//  APIClientTest.swift
//  SmartScanTests
//
//  Created by Chien Nguyen on 3/23/24.
//

import XCTest

import XCTest
@testable import SmartScan

public struct EmployeeResponse: Codable {
    var status: String
    var data: [Employee]
    var message: String
}

public struct Employee: Codable {
    var id: Int
    var employee_name: String
    var employee_salary: Int
    var employee_age: Int
    var profile_image: String
}

public struct GetEmployees: APIRequest {
    public var method = HTTPMethod.get
    public var path = "/api/v1/employees"
    public var parameters = [String: String]()
    public var httpHeader = [String: String]()
    public var httpBody: Data?
    
    public typealias Response = EmployeeResponse

}

final class APIClientTest: XCTestCase {

    func testGetEmployees(){
        let expectations = expectation(description: "Get Employees")
        let apiClient = APIClient()
        apiClient.baseURL = URL(string: "https://dummy.restapiexample.com/")!
        let request = GetEmployees()
        apiClient.send(request) { response in
            print("\nGetEmployees finished: \(response)")
            expectations.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testGetEmployees_Task(){
        let expectations = expectation(description: "Get Employees")
        Task{
            let apiClient = APIClient()
            apiClient.baseURL = URL(string: "https://dummy.restapiexample.com/")!
            let request = GetEmployees()
            do {
                let model = try await apiClient.send(request).data
                print(model)
                expectations.fulfill()
            } catch {
                print("error")
                expectations.fulfill()
            }
        }
        waitForExpectations(timeout: 20, handler: nil)
    }

}
