import SwiftUI
import AVFoundation
import CoreLocation
import Vision

class CameraViewModel: NSObject, ObservableObject {
    @Published var hasPermissions = false
    @Published var capturedImage: UIImage?
    @Published var isProcessing = false
    @Published var detectionResults: CarDetectionResult?
    @Published var errorMessage: String?
    
    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
        checkPermissions()
    }
    
    func requestPermissions() {
        requestCameraPermission()
        requestLocationPermission()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.checkPermissions()
            }
        }
    }
    
    private func requestLocationPermission() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func checkPermissions() {
        let cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        let locationPermission = locationManager?.authorizationStatus
        
        hasPermissions = cameraPermission == .authorized && 
                        (locationPermission == .authorizedWhenInUse || locationPermission == .authorizedAlways)
        
        if hasPermissions {
            setupCamera()
        }
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        captureSession.beginConfiguration()
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access back camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            captureSession.commitConfiguration()
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startCamera() {
        guard let captureSession = captureSession else { return }
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    func stopCamera() {
        captureSession?.stopRunning()
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        locationManager?.requestLocation()
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func getCaptureSession() -> AVCaptureSession? {
        return captureSession
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to capture photo"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.processImage(image)
        }
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        let carDetector = CarDetectionService()
        
        carDetector.detectCarInImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let detectionResult):
                    if detectionResult.carDetected {
                        // Update result with current location if available
                        var finalResult = detectionResult
                        if let location = self?.currentLocation {
                            finalResult = CarDetectionResult(
                                carDetected: detectionResult.carDetected,
                                licenseplate: detectionResult.licenseplate,
                                make: detectionResult.make,
                                model: detectionResult.model,
                                location: location,
                                timestamp: detectionResult.timestamp,
                                confidence: detectionResult.confidence
                            )
                        }
                        self?.detectionResults = finalResult
                    } else {
                        self?.errorMessage = "No car detected in the image"
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

extension CameraViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkPermissions()
    }
}
