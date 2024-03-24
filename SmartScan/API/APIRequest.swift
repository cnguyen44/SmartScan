//
//  APIRequest.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation

/// HTTP methods for APIClient
public enum HTTPMethod: String{
    case get, post, put, delete, patch
}

/// API errors
public enum APIError: Error{
    case encoding
    case decoding
    case server(error: ServerError)
    case other(Error)
    
    static func map(_ error: Error)->APIError{
        return (error as? APIError) ?? .other(error)
    }
}

/// Server errors
public struct ServerError: Codable{
    let error: String
}

/// APIRequest
public protocol APIRequest {
    associatedtype Response: Decodable
    
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: String] { get }
    var httpHeader: [String: String] { get }
    var httpBody: Data? { get }
}

public struct APIResponse: Decodable {
    var statusCode: Int?
    var data: Data?
}

extension APIRequest {
    func request(with baseURL: URL)->URLRequest?{
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else{
            return nil
        }
        components.queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        guard let url = components.url else{
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeader
        request.httpBody = httpBody
        
        return request
    }
}
