//
//  CarService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation

enum CarServiceError: Error {
    case serverError
}

typealias CarServiceCompletionHandler = (Result<(Car), CarServiceError>) -> Void

class CarService{
    func getVehicle(vin: String, handler: @escaping CarServiceCompletionHandler){
        let apiClient = APIClient(baseURL: URL(string: DataManager.shared.vinEndpoint)!)
        let request = GetCarRequest(vin: vin)
        apiClient.send(request) { response in
            print("Get Car finished: \(response)")
            switch response{
            case .success(let response):
                guard let car = response.results?.first else{
                    handler(.failure(.serverError))
                    return
                }
                handler(.success(car))
            case .failure (let error):
                print(error)
                handler(.failure(.serverError))
            }
        }
        
    }
}
