//
//  ScanVINService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import Vision

///A service that scan and recognize license plate.
///Out put is ``ScanData`` that contains vin
class ScanVINService: ScanService {
    ///Create requests. Use barcode detection and text recognition to detect vin
    override func getRequests(image: CVPixelBuffer) -> [VNRequest] {
        var requests = [VNRequest]()
        
        let detectBarcodeRequest = VNDetectBarcodesRequest(completionHandler: { (request, error) in
            self.requestHandler(image: image, request: request, error: error)
        })
        requests.append(detectBarcodeRequest)
        
        let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            self.requestHandler(image: image, request: request, error: error)
        })
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = false
        requests.append(recognizeTextRequest)
        
        return requests
    }
    
    ///Handle result from VNDetectBarcodesRequest and VNRecognizeTextRequest
    override func requestHandler(image: CVPixelBuffer, request: VNRequest, error: Error?) {
        guard let results = request.results else{
            return
        }
        var dataList = [ScanData]()
        ///Process observation
        for result in results{
            if let observation = result as? VNBarcodeObservation{
                guard var vin = observation.payloadStringValue else{
                    continue
                }
                ///Some company add one extra character infront of vin, remove this character
                if vin.count == 18 {
                    vin.remove(at: vin.startIndex)
                }
                guard Car.validateVIN(text: vin) else {
                    continue
                }
                let data = ScanData(confident: observation.confidence, result: vin, boundingBox: observation.boundingBox)
                dataList.append(data)
            }
            else if let observation = result as? VNRecognizedTextObservation {
                guard let text = observation.topCandidates(1).first?.string else {
                    continue
                }
                let texts = text.components(separatedBy: " ")
                for vin in texts {
                    guard vin.count == 17, Car.validateVIN(text: vin) else {
                        continue
                    }
                
                    let data = ScanData(confident: observation.confidence, result: vin, boundingBox: observation.boundingBox)
                    dataList.append(data)
                }
            }
            else{
                print("Request did not return recognized objects")
            }
        }
        
        self.scanServiceCompletionHandler?(.success(dataList))
    }
}
