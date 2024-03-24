//
//  ARAnnotationService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import ARKit
import RealityKit
import Combine

enum ARAnnotationStyle: String, Codable {
    case targetSquare, targetCircle, sphere
    
}

class ARAnnotationService: ARService{
    var annotationStyle = ARAnnotationStyle.targetSquare
    var canAddAnnotation = false
    private var anchorEntityMap = [String: AnchorEntity]()
    private var entityTapListener: ((String)->Void)?
    
    var annotationText: String{
        if let count = self.arView?.scene.anchors.count{
            return "\(count+1)"
        }
        return "1"
    }
    
    private var count: Int{
        if let count = self.arView?.scene.anchors.count{
            return count+1
        } else {
            return 1
        }
    }
    
    //MARK: Service calls
    func removePreviousAnnotation(){
        guard let count = self.arView?.scene.anchors.count, count > 0 else{
            return
        }
        self.arView?.scene.anchors.remove(at: count-1)
    }
    
    func removeAnnotations(){
        self.arView?.scene.anchors.removeAll()
    }
    
    
    //MARK: Setup
    override func arConfiguration() -> ARConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        
//        configuration.sceneReconstruction = .mesh
//        arView?.debugOptions.insert(.showSceneUnderstanding)
//        arView?.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        return configuration
    }
    
    override func setupARView() {
        super.setupARView()
        //Tap on view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(arViewTapped(_:)))
        arView?.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func arViewTapped(_ sender: UITapGestureRecognizer) {

        let tapLocation = sender.location(in: arView)
        print("Tap location: \(tapLocation)")
    
        guard canAddAnnotation else{
            if let entity = self.arView?.entity(at: tapLocation){
                // handle tap on the entity
                self.entityTapListener?(entity.name)
            }
            return
        }
        
        #if !targetEnvironment(simulator)
        guard let result = arView?.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first else{
            return
        }
        print("RayCast: \(result)")
        let resultAnchor = AnchorEntity(world: result.worldTransform)
        let (entity, _) = self.getEntity()

        resultAnchor.addChild(entity)
        arView?.scene.addAnchor(resultAnchor)

        // Move around entity with finger
        entity.generateCollisionShapes(recursive: true)
        arView?.installGestures(for: entity as! Entity & HasCollision)
        #endif
    }
    
    private func getEntity()->(Entity,Int) {
        let entity: Entity
        let num = count
        
        switch annotationStyle {
        case .targetSquare, .targetCircle:
            entity = self.loadUSDZEntity(style: annotationStyle, scale: 0.001)
        case .sphere:
            entity = self.sphere(radius: 0.025, color: .blue)
        }
        
        return (entity, num)
    }
    
    private func loadUSDZEntity(style: ARAnnotationStyle, scale: Float = 1.0)->Entity{
        let entity = ARDataManager.shared.annotationEntities[style.rawValue]!.clone(recursive: true)
        entity.setScale(SIMD3(repeating: scale), relativeTo: nil)
        
        let parentEntity = ModelEntity()
        parentEntity.name = entity.name
        parentEntity.addChild(entity)
        let entityBounds = entity.visualBounds(relativeTo: parentEntity)
        parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: entityBounds.extents).offsetBy(translation: entityBounds.center)])
        parentEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
        parentEntity.physicsMotion = PhysicsMotionComponent()
        return parentEntity
    }
}

extension ARAnnotationService{
    func sphere(radius: Float, color: UIColor) -> ModelEntity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        // Move sphere up by half its diameter so that it does not intersect with the mesh
        sphere.position.y = radius
        return sphere
    }
}


