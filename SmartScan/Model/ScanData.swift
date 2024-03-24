//
//  ScanData.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import UIKit
import Vision

struct ScanData: Codable{
    var confident: Float?
    var result: String?
    var boundingBox: CGRect?
}
