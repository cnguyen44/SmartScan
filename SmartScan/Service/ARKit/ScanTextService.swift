//
//  ScanTextService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import Vision

///A service that scan and recognize text.
class ScanTextService: ScanService {
    ///Create requests. Use text recognition to detect text
    override func getRequests(image: CVPixelBuffer) -> [VNRequest] {
        var requests = [VNRequest]()
        
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
            if let observation = result as? VNRecognizedTextObservation {
                guard let text = observation.topCandidates(1).first?.string else {
                    continue
                }
                
                let data = ScanData(confident: observation.confidence, result: text, boundingBox: observation.boundingBox)
                dataList.append(data)
                
                //Draw box around recognize text
                self.drawBoxes(observations: dataList)
            }
            else{
                print("Request did not return recognized objects")
            }
        }
        
        self.scanServiceCompletionHandler?(.success(dataList))
    }
}
