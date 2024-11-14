//
//  VisionObjectRecognitionViewController.swift
//  Heron_RecipeApp
//
//  Created by  ao2844 on 11/14/24.
//

import SwiftUI
import AVFoundation
import Vision
class VisionObjectRecognitionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var requests = [VNRequest]()
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer! = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    var bufferSize: CGSize = .zero
    var rootLayer: CALayer! = nil
    
    // String array that stores the scanned ingredients
    private var detectedFoods: [String] = [] {
        didSet{
            reportFood()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        setupVision()
        reportFood()
    }
    
    // Prints food array when it changes
    private func reportFood() {
        let foodText = detectedFoods.isEmpty ?
            "No foods detected yet" :
            "Detected Foods:\n" + detectedFoods.joined(separator: "\n")
        print("Updating label with text: \(foodText)")
    }
    
    // Sets up the Vision framework to use a Core ML model
    private func setupVision(){
        guard let modelURL = Bundle.main.url(forResource: "TomatoOnionDetector", withExtension: "mlmodelc") else {
            return
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let classificationRequest = VNCoreMLRequest(model: visionModel) {
                [weak self] request, error in self?.processClassifications(for: request, error: error)
            }
            self.requests = [classificationRequest]
        } catch{
            print("Model loading went wrong: \(error)")
        }
    }
    
    // Extracts image data whenever there's a new frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    // Processes the ingredient classification and adds it to food array if not seen before
    private func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        let highConfidenceResults = results.filter { $0.confidence > 0.8 }
        
        if let topResult = highConfidenceResults.first, let topLabel = topResult.labels.first {
            DispatchQueue.main.async { [weak self] in
                if !(self?.detectedFoods.contains(topLabel.identifier) ?? true) {
                    self?.detectedFoods.append(topLabel.identifier)
                }
            }
        }
    }
    
    // Starts capturing with AVFoundation. Shows the camera view to the user
    func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Access the phone camera
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        // Start setting up the session configuration
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        
        // Start the session asynchronously on a background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.previewLayer = AVCaptureVideoPreviewLayer(session: self?.session ?? AVCaptureSession())
                self?.previewLayer.videoGravity = .resizeAspectFill
                self?.rootLayer = self?.view.layer
                self?.previewLayer.frame = CGRect(x: 0, y: 0, width: self?.view.frame.width ?? 0, height: self?.view.frame.height ?? 0)
                self?.rootLayer?.addSublayer(self?.previewLayer ?? CALayer())
            }
        }
    }
}
