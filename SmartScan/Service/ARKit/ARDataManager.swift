//
//  ARDataManager.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import Combine
import RealityKit
import ARKit

class ARDataManager {
    static let shared = ARDataManager()
    
    //Make init private to stops other parts of our code from trying to create a MySingleton class instance
    private init() { }
    
    private let annotationFilenames = ["targetSquare","targetCircle","targetCircle2"]
    var annotationEntities = [String:Entity]()
    private var streams = [Combine.AnyCancellable]()
    
    public func loadDataFromAppBundle(){
        //Load annotattions from usdz file
        self.annotationEntities.removeAll()
        for filename in annotationFilenames{
            if let usdzURL = Bundle.main.url(forResource: filename, withExtension: "usdz"){
                if let entity = self.loadEntity(archiveURL: usdzURL, filename: filename){
                    self.annotationEntities[filename] = entity
                }
            }
        }
    }
    
    //Synchronous load Entity
    func loadEntity(archiveURL: URL, filename: String)->Entity?{
        do{
            let entity = try Entity.load(contentsOf: archiveURL, withName: nil)
            entity.name = filename
            return entity
        }
        catch{
            return nil
        }
    }
}
