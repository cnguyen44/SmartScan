//
//  Car.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation

struct Car:Codable{
    var id: String?
    var vin: String?
    var year: Int16?
    var make: String?
    var model: String?
    var series: String?
    var trim: String?
    
    enum NHTSACodingKeys: String, CodingKey {
        case vin = "VIN"
        case year = "ModelYear"
        case make = "Make"
        case model = "Model"
        case series = "Series"
        case trim = "Trim"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NHTSACodingKeys.self)
        id = UUID().uuidString
        vin = try? container.decode(String.self, forKey: .vin)
        if let yearString = try? container.decode(String.self, forKey: .year){
            year = Int16(yearString)
        }
        make = try? container.decode(String.self, forKey: .make)
        model = try? container.decode(String.self, forKey: .model)
        series = try? container.decode(String.self, forKey: .series)
        trim = try? container.decode(String.self, forKey: .trim)
    }
    
    func yearString()->String?{
        guard let year = year else{
            return nil
        }
        return String(year)
    }
    
    static func validateVIN(text: String)->Bool{
        let VINRegEx = "[A-HJ-NPR-Z0-9]{17}"
        let VINPred = NSPredicate(format:"SELF MATCHES %@", VINRegEx)
        return VINPred.evaluate(with: text)
    }
}
