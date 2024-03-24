//
//  ScanService.swift
//  SmartScan
//
//  Created by Chien Nguyen on 3/23/24.
//

import Foundation
import ARKit
typealias ScanServiceCompletionHandler = (Result<[ScanData], ARServiceError>) -> ()

class ScanService: ARService {
    var deviceOrientation = UIDevice.current.orientation
    var frameCount = 0
    var scanServiceCompletionHandler: ScanServiceCompletionHandler?
    
    /// Concurrent queue to be used for model predictions
    private let predictionQueue = DispatchQueue(label: "predictionQueue", qos: .userInitiated,
                                        attributes: [],
                                        autoreleaseFrequency: .inherit,
                                        target: nil)
    private var bufferSize: CGSize! {
        didSet {
            if bufferSize != nil {
                if oldValue == nil {
                    setupLayers()
                } else if oldValue != bufferSize {
                    updateDetectionOverlaySize()
                }
            }
        }
    }
    
    private var viewSize = CGSize.zero
    
    /// Layer used to host detectionOverlay layer
    private var rootLayer: CALayer!
    /// The detection overlay layer used to render bounding boxes
    private var detectionOverlay: CALayer!
    
    //MARK: init
    override init(){
        super.init()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    //MARK: Service calls
    func prepareScan(_ completionHandler: @escaping ScanServiceCompletionHandler){
        self.scanServiceCompletionHandler = completionHandler
        self.prepare { result in
            switch result{
            case .success(_):
                break
            case .failure(let error):
                self.scanServiceCompletionHandler?(.failure(error))
            }
        }
    }
    
    override func start(){
        self.frameCount = 0
        super.start()
    }
    
    override func stop(){
        super.stop()
        self.bufferSize = nil
        self.viewSize = CGSize.zero
    }
    
    //MARK: Setup
    override func arConfiguration() -> ARConfiguration {
        return ARImageTrackingConfiguration()
    }
    
    override func setupARView(){
        super.setupARView()
        rootLayer = view.layer
    }
    
    func getRequests(image: CVPixelBuffer)->[VNRequest]{
        fatalError("Use subclass!")
    }
    
    func requestHandler(image: CVPixelBuffer, request: VNRequest, error: Error?){
        fatalError("Use subclass!")
    }
    
    //MARK: ARSessionDelegate
    override func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //Limit coreml request per frame to reduce CPU usage
        //Live video frame rate is 60FPS
        if self.frameCount % 30 != 0 {
            self.frameCount += 1
            return
        }
        self.frameCount += 1
        predictionQueue.async {
            //Image orientation
            let imageOrientation: CGImagePropertyOrientation
            switch self.deviceOrientation {
            case .portrait:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .left
            case .landscapeLeft:
                imageOrientation = .up
            case .landscapeRight:
                imageOrientation = .down
            case .unknown:
                print("The device orientation is unknown, the predictions may be affected")
                fallthrough
            default:
                imageOrientation = .right
            }
            
            //Get image buffer size
            let imageBuffer = frame.capturedImage
            if self.bufferSize == nil{
                let pixelBufferWidth = CVPixelBufferGetWidth(imageBuffer)
                let pixelBufferHeight = CVPixelBufferGetHeight(imageBuffer)
                if [.up, .down].contains(imageOrientation) {
                        self.bufferSize = CGSize(width: pixelBufferWidth,
                                                 height: pixelBufferHeight)
                    } else {
                        self.bufferSize = CGSize(width: pixelBufferHeight,
                                                 height: pixelBufferWidth)
                    }
            }
            
            //Invoke a VNRequestHandler with imageBuffer
            do {
                let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: imageOrientation, options: [:])
                try handler.perform(self.getRequests(image: imageBuffer))
            }
            catch {
                print(error)
            }
            
            DispatchQueue.main.async {
                if !self.viewSize.equalTo(self.view.bounds.size){
                    self.viewSize = self.view.bounds.size
                    self.updateDetectionOverlaySize()
                }
            }
        }
    }
}

//MARK: Draw on layer for object detection
extension ScanService{
    
    /// Removes all bounding boxes from the screen
    func removeBoxes() {
        drawBoxes(observations: [])
    }

    /// Draws bounding boxes based on the object observations
    ///
    /// - parameter observations: The list of object observations from the object detector
    func drawBoxes(observations: [ScanData]) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.detectionOverlay.sublayers = nil // remove all the old recognized objects

            for observation in observations {
                // Select only the label with the highest confidence.
                guard let topLabel = observation.result else {
                    print("Object observation has no labels")
                    continue
                }

                let objectBounds = self.bounds(for: observation)

                let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds, identifier: topLabel)
                let textLayer = self.createTextSubLayerInBounds(objectBounds, identifier: topLabel)
                shapeLayer.addSublayer(textLayer)
                self.detectionOverlay.addSublayer(shapeLayer)
            }

            self.updateLayerGeometry()
            CATransaction.commit()
        }
    }
    
    func layer(from point: CGPoint)->CALayer?{
        guard let layers = self.detectionOverlay.sublayers else {
            return nil
        }
        for layer in layers{
            if layer.contains(point){
                return layer
            }
        }
        return nil
    }
    
    func bounds(for observation: ScanData) -> CGRect {
        guard let boundingBox = observation.boundingBox else {
            return self.view.bounds
        }
        // Coordinate system is like macOS, origin is on bottom-left and not top-left

        // The resulting bounding box from the prediction is a normalized bounding box with coordinates from bottom left
        // It needs to be flipped along the y axis
        let fixedBoundingBox = CGRect(x: boundingBox.origin.x,
                                      y: 1.0 - boundingBox.origin.y - boundingBox.height,
                                      width: boundingBox.width,
                                      height: boundingBox.height)

        // Return a flipped and scaled rectangle corresponding to the coordinates in the sceneView
        return VNImageRectForNormalizedRect(fixedBoundingBox, Int(self.view.frame.width), Int(self.view.frame.height))
    }
    
    /// Sets up CALayers for rendering bounding boxes
    func setupLayers() {
        DispatchQueue.main.async {
            self.detectionOverlay = CALayer() // container layer that has all the renderings of the observations
            self.detectionOverlay.name = "DetectionOverlay"
            self.detectionOverlay.bounds = CGRect(x: 0.0,
                                                  y: 0.0,
                                                  width: self.view.frame.width,
                                                  height: self.view.frame.height)
            self.detectionOverlay.position = CGPoint(x: self.rootLayer.bounds.midX,
                                                     y: self.rootLayer.bounds.midY)
            self.rootLayer.addSublayer(self.detectionOverlay)
        }
    }

    /// Update the size of the overlay layer if the sceneView size changed
    func updateDetectionOverlaySize() {
        DispatchQueue.main.async {
            self.detectionOverlay.bounds = CGRect(x: 0.0,
                                                  y: 0.0,
                                                  width: self.view.frame.width,
                                                  height: self.view.frame.height)
        }
    }

    /// Update layer geometry when needed
    func updateLayerGeometry() {
        DispatchQueue.main.async {
            let bounds = self.rootLayer.bounds
            var scale: CGFloat

            let xScale: CGFloat = bounds.size.width / self.view.frame.height
            let yScale: CGFloat = bounds.size.height / self.view.frame.width

            scale = fmax(xScale, yScale)
            if scale.isInfinite {
                scale = 1.0
            }
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

            self.detectionOverlay.position = CGPoint(x: bounds.midX, y: bounds.midY)

            CATransaction.commit()
        }
    }

    /// Creates a text layer to display the label for the given box
    ///
    /// - parameters:
    ///     - bounds: Bounds of the detected object
    ///     - identifier: Class label for the detected object
    ///     - confidence: Confidence in the prediction
    /// - returns: A newly created CATextLayer
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let attributedString = NSMutableAttributedString(string: "\(identifier)")
        let largeFont = UIFont(name: "Helvetica", size: 12.0)!
        let attributes = [NSAttributedString.Key.font: largeFont, NSAttributedString.Key.foregroundColor: UIColor.white]
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: identifier.count))
        textLayer.string = attributedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.0
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        return textLayer
    }

    /// Creates a reounded rectangle layer with the given bounds
    /// - parameter bounds: The bounds of the rectangle
    /// - returns: A newly created CALayer
    func createRoundedRectLayerWithBounds(_ bounds: CGRect, identifier: String) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.name = identifier
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.8, 1.0, 0.6])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
}
