//
//  APIClient.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

/**
 TODO:
 - Use access token when send request:
 request.setValue("Bearer: \(accessToken)", forHTTPHeaderField: "Authorization")
 - Certificate pinning from URLSessionDelegate
 urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge)
 */

import Foundation

public typealias ResultCallback<Value> = (Result<Value, Error>) -> Void

/**
 APIClient makes network request to server
   - Parameter request: the APIRequest for which to create a data task
   - Parameter completionHandler: block that return Codable data and APIError
 */
public final class APIClient {
    private let baseURL:URL
    private let session = URLSession(configuration: .default)
    
    public init(baseURL: URL){
        self.baseURL = baseURL
    }
    
    //Send APIRequest with block
    public func send<T:APIRequest>(_ request: T, completion: @escaping ResultCallback<T.Response>) {
        guard let req = request.request(with: baseURL) else{
            completion(.failure(APIError.encoding))
            return
        }
        
        let task = session.dataTask(with: req) { (data, response, error) in
            if let error = error{
                completion(.failure(APIError.map(error)))
                return
            }
            //APIResponse type, return status code and raw data
            if T.Response.self == APIResponse.self{
                let model: T.Response
                var statusCode: Int?
                if let httpURLResponse = response as? HTTPURLResponse{
                    statusCode = httpURLResponse.statusCode
                    
                }
                model = APIResponse(statusCode: statusCode, data: data) as! T.Response
                completion(.success(model))
            }
            else{
                //Check if server return some error
                do{
                    let serverError: ServerError = try JSONDecoder().decode(ServerError.self, from: data ?? Data())
                    completion(.failure(APIError.server(error: serverError)))
                }
                //No error from server, try to decode data
                catch{
                    do{
                        let model: T.Response = try JSONDecoder().decode(T.Response.self, from: data ?? Data())
                        completion(.success(model))
                    }
                    catch {
                        print(String(data: data!, encoding: .utf8) ?? "")
                        completion(.failure(APIError.decoding))
                    }
                }
            }
        }
        task.resume()
    }
    
    //Send APIRequest with async
    public func send<T:APIRequest>(_ request: T) async throws -> T.Response {
        guard let req = request.request(with: baseURL) else{
            throw APIError.encoding
        }
        let (data, response) = try await session.data(for: req)
        
        //APIResponse type, return status code and raw data
        if T.Response.self == APIResponse.self{
            let model: T.Response
            var statusCode: Int?
            if let httpURLResponse = response as? HTTPURLResponse{
                statusCode = httpURLResponse.statusCode
                
            }
            model = APIResponse(statusCode: statusCode, data: data) as! T.Response
            return model
        }
        else{
            //Check if server return some error
            do{
                let serverError: ServerError = try JSONDecoder().decode(ServerError.self, from: data)
                throw APIError.server(error: serverError)
            }
            //No error from server, try to decode data
            catch{
                do{
                    return try JSONDecoder().decode(T.Response.self, from: data)
                }
                catch {
                    print(String(data: data, encoding: .utf8) ?? "")
                    throw APIError.decoding
                }
            }
        }
    }
}

/**
 MockAPIClient for testing
 */
public final class MockAPIClient {
    var baseURL = URL(string: "DataCenter.shared.endpoint")!
    
    //Send APIRequest with block
    public func send<T:APIRequest>(_ request: T, completion: @escaping ResultCallback<T.Response>) {
        
        //Load data from file
        var filePath = ""
        var data: Data?
        
        if T.Response.self == GetUserResponse.self{
            filePath = "user"
        }
        
        MockAPIClient.loadJsonDataFromFile(filePath, completion: { d in
            data = d
        })
        
        do{
            let model: T.Response = try JSONDecoder().decode(T.Response.self, from: data ?? Data())
            completion(.success(model))
        }
        catch {
            print(String(data: data!, encoding: .utf8) ?? "")
            completion(.failure(APIError.decoding))
        }
    }
    
    private static func loadJsonDataFromFile(_ path: String, completion: (Data?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: path, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                completion(data as Data)
            } catch (let error) {
                print(error.localizedDescription)
                completion(nil)
            }
        }
    }
}
