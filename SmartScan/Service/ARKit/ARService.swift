//
//  ARService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import ARKit
import RealityKit

enum ARServiceState: String {
    case undetermined, active, inactive, notAvailable, denied, approved
}

enum ARServiceError: Error {
    case serviceFailed(String)
}

typealias ARServiceCompletionHandler = (Result<Bool, ARServiceError>) -> ()

class ARService: NSObject {
    var state = ARServiceState.undetermined
    var view = UIView()
    var completionHandler: ARServiceCompletionHandler?
    
    var arView: ARView?
    private var arSession: ARSession? {
        #if !targetEnvironment(simulator)
        return arView?.session
        #else
        return nil
        #endif
    }
    
    //MARK: init
    override init(){
        super.init()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    //MARK: Class functions
    class func requestUserPermission(completionHandler: @escaping (Bool)->Void){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completionHandler(granted)
                }
            }
        case .authorized:
            completionHandler(true)
        case .denied, .restricted:
            completionHandler(false)
        @unknown default:
            completionHandler(false)
        }
    }
    
    //MARK: Service calls
    func prepare(_ completionHandler: @escaping ARServiceCompletionHandler){
        self.completionHandler = completionHandler
        
        ARService.requestUserPermission { granted in
            if granted{
                self.start()
                self.completionHandler?(.success(true))
            }
            else{
                self.completionHandler?(.failure(.serviceFailed("Need user permission")))
            }
        }
    }
    
    func start(){
        self.setupARView()
        self.arSession?.run(self.arConfiguration())
        self.state = .active
    }
    
    func stop(){
        self.arSession?.pause()
        self.removeARView()
        self.state = .inactive
    }
    
    //MARK: Setup
    func arConfiguration()->ARConfiguration{
        return ARWorldTrackingConfiguration()
    }
    
    func setupARView(){
        arView = ARView()
        view.addSubview(arView!)
        arSession?.delegate = self
        
        #if !targetEnvironment(simulator)
        //Configuration
        arView?.automaticallyConfigureSession = false
        #endif
        
        //Constraint
        arView?.translatesAutoresizingMaskIntoConstraints = false
        let views = ["arView": arView!]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[arView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[arView]|", options: [], metrics: nil, views: views))
    }
    
    func removeARView(){
        arSession?.delegate = nil
        arView?.removeFromSuperview()
        arView = nil
    }
}

//MARK: ARSessionDelegate
extension ARService: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {

    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print(camera.trackingState)
    }
    
    //MARK: ARAnchor
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("ARSession didAdd anchors")
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        print("ARSession didRemove anchors")
    }
    
    //MARK: ARSessionObserver
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("sessionWasInterrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("sessionInterruptionEnded")
    }
}
