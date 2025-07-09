import Foundation
import UIKit
import CoreLocation
import AVFoundation
@testable import CarRecognitionApp

// MARK: - Mock Car Detection Service

class MockCarDetectionService: CarDetectionService {
    var shouldDetectCar: Bool = true
    var mockLicensePlate: String? = "TEST123"
    var mockMake: String? = "Toyota"
    var mockModel: String? = "Camry"
    var mockLocation: CLLocation? = CLLocation(latitude: 37.7749, longitude: -122.4194)
    var mockConfidence: Float = 0.85
    var shouldFailDetection: Bool = false
    
    override func detectCarInImage(_ image: UIImage, completion: @escaping (Result<CarDetectionResult, Error>) -> Void) {
        // Simulate processing delay
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            if self.shouldFailDetection {
                completion(.failure(CarDetectionError.processingError))
                return
            }
            
            let result = CarDetectionResult(
                carDetected: self.shouldDetectCar,
                licenseplate: self.shouldDetectCar ? self.mockLicensePlate : nil,
                make: self.shouldDetectCar ? self.mockMake : nil,
                model: self.shouldDetectCar ? self.mockModel : nil,
                location: self.mockLocation,
                timestamp: Date(),
                confidence: self.shouldDetectCar ? self.mockConfidence : 0.0
            )
            
            completion(.success(result))
        }
    }
}

// MARK: - Mock Car Identification Service

class MockCarIdentificationService: CarIdentificationService {
    var mockMake: String? = "Honda"
    var mockModel: String? = "Civic"
    var shouldFailIdentification: Bool = false
    
    override func identifyCarMakeAndModel(from image: UIImage, completion: @escaping (Result<(make: String?, model: String?), Error>) -> Void) {
        // Simulate processing delay
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
            if self.shouldFailIdentification {
                completion(.failure(CarIdentificationError.processingError))
                return
            }
            
            completion(.success((make: self.mockMake, model: self.mockModel)))
        }
    }
}

// MARK: - Mock Location Manager

class MockLocationManager: CLLocationManager {
    var mockLocation: CLLocation?
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    override func requestWhenInUseAuthorization() {
        mockAuthorizationStatus = .authorizedWhenInUse
        delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    override func requestLocation() {
        if let location = mockLocation {
            delegate?.locationManager?(self, didUpdateLocations: [location])
        } else {
            let error = NSError(domain: "MockLocationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock location error"])
            delegate?.locationManager?(self, didFailWithError: error)
        }
    }
}

// MARK: - Mock Camera Capture Session

class MockCaptureSession: AVCaptureSession {
    var isRunningMock: Bool = false
    
    override func startRunning() {
        isRunningMock = true
    }
    
    override func stopRunning() {
        isRunningMock = false
    }
    
    override var isRunning: Bool {
        return isRunningMock
    }
}

// MARK: - Mock Photo Output

class MockPhotoOutput: AVCapturePhotoOutput {
    var mockImageData: Data?
    
    override func capturePhoto(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        // Simulate photo capture
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let mockPhoto = MockCapturePhoto(imageData: self.mockImageData)
            delegate.photoOutput?(self, didFinishProcessingPhoto: mockPhoto, error: nil)
        }
    }
}

// MARK: - Mock Capture Photo

class MockCapturePhoto: AVCapturePhoto {
    private let mockImageData: Data?
    
    init(imageData: Data?) {
        self.mockImageData = imageData
        super.init()
    }
    
    override func fileDataRepresentation() -> Data? {
        return mockImageData ?? createMockImageData()
    }
    
    private func createMockImageData() -> Data {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData() ?? Data()
    }
}

// MARK: - Test Utilities

class TestUtilities {
    static func createTestImage(color: UIColor = .blue, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    static func createCarTestImage() -> UIImage {
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Create a simple car-like shape for testing
            let rect = CGRect(origin: .zero, size: size)
            
            // Background
            UIColor.lightGray.setFill()
            context.fill(rect)
            
            // Car body
            UIColor.blue.setFill()
            let carBody = CGRect(x: 50, y: 150, width: 300, height: 100)
            context.fill(carBody)
            
            // License plate area
            UIColor.white.setFill()
            let licensePlate = CGRect(x: 180, y: 200, width: 80, height: 30)
            context.fill(licensePlate)
            
            // Add some text to simulate license plate
            let text = "ABC123"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            attributedText.draw(at: CGPoint(x: 190, y: 210))
            
            // Wheels
            UIColor.black.setFill()
            let leftWheel = CGRect(x: 80, y: 220, width: 40, height: 40)
            let rightWheel = CGRect(x: 280, y: 220, width: 40, height: 40)
            context.fill(leftWheel)
            context.fill(rightWheel)
        }
    }
    
    static func createMockDetectionResult(
        carDetected: Bool = true,
        licenseplate: String? = "TEST123",
        make: String? = "Toyota",
        model: String? = "Camry",
        location: CLLocation? = CLLocation(latitude: 37.7749, longitude: -122.4194),
        confidence: Float = 0.85
    ) -> CarDetectionResult {
        return CarDetectionResult(
            carDetected: carDetected,
            licenseplate: licenseplate,
            make: make,
            model: model,
            location: location,
            timestamp: Date(),
            confidence: confidence
        )
    }
}

// MARK: - Test Extensions

extension XCTestCase {
    func waitForExpectations(timeout: TimeInterval = 5.0, handler: XCWaitCompletionHandler? = nil) {
        waitForExpectations(timeout: timeout, handler: handler)
    }
    
    func createExpectation(description: String) -> XCTestExpectation {
        return XCTestExpectation(description: description)
    }
}
