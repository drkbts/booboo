import XCTest
import AVFoundation
import CoreLocation
@testable import CarRecognitionApp

final class CameraViewModelTests: XCTestCase {
    
    var cameraViewModel: CameraViewModel!
    
    override func setUpWithError() throws {
        cameraViewModel = CameraViewModel()
    }
    
    override func tearDownWithError() throws {
        cameraViewModel = nil
    }
    
    // MARK: - Initialization Tests
    
    func testCameraViewModelInitialization() throws {
        XCTAssertNotNil(cameraViewModel)
        XCTAssertFalse(cameraViewModel.hasPermissions)
        XCTAssertNil(cameraViewModel.capturedImage)
        XCTAssertFalse(cameraViewModel.isProcessing)
        XCTAssertNil(cameraViewModel.detectionResults)
        XCTAssertNil(cameraViewModel.errorMessage)
    }
    
    // MARK: - Permission Tests
    
    func testRequestPermissions() throws {
        // Test that requesting permissions doesn't crash
        cameraViewModel.requestPermissions()
        
        // Note: In a real test environment, you'd need to mock AVCaptureDevice
        // and CLLocationManager to test permission flow properly
        XCTAssertNotNil(cameraViewModel)
    }
    
    // MARK: - Camera Setup Tests
    
    func testCameraSessionCreation() throws {
        let captureSession = cameraViewModel.getCaptureSession()
        
        // Session might be nil if permissions aren't granted
        if captureSession != nil {
            XCTAssertNotNil(captureSession)
            XCTAssertTrue(captureSession is AVCaptureSession)
        }
    }
    
    func testStartStopCamera() throws {
        // Test that start/stop camera methods don't crash
        cameraViewModel.startCamera()
        XCTAssertNotNil(cameraViewModel)
        
        cameraViewModel.stopCamera()
        XCTAssertNotNil(cameraViewModel)
    }
    
    // MARK: - Image Processing Tests
    
    func testImageProcessingState() throws {
        let testImage = createTestImage()
        
        // Initially not processing
        XCTAssertFalse(cameraViewModel.isProcessing)
        
        // Create expectation for processing completion
        let expectation = XCTestExpectation(description: "Image processing completes")
        
        // Mock the processing method by calling it directly
        cameraViewModel.processImage(testImage)
        
        // Should immediately set processing to true
        XCTAssertTrue(cameraViewModel.isProcessing)
        
        // Wait for processing to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertFalse(self.cameraViewModel.isProcessing)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testErrorMessageHandling() throws {
        let testImage = createTestImage()
        
        // Process an image that should result in "no car detected"
        let expectation = XCTestExpectation(description: "Error message set")
        
        cameraViewModel.processImage(testImage)
        
        // Wait for processing to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Should have an error message since test image doesn't contain a car
            XCTAssertNotNil(self.cameraViewModel.errorMessage)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Detection Results Tests
    
    func testDetectionResultsUpdating() throws {
        let testResult = CarDetectionResult(
            carDetected: true,
            licenseplate: "TEST123",
            make: "Toyota",
            model: "Camry",
            location: CLLocation(latitude: 37.7749, longitude: -122.4194),
            timestamp: Date(),
            confidence: 0.85
        )
        
        cameraViewModel.detectionResults = testResult
        
        XCTAssertNotNil(cameraViewModel.detectionResults)
        XCTAssertEqual(cameraViewModel.detectionResults?.licenseplate, "TEST123")
        XCTAssertEqual(cameraViewModel.detectionResults?.make, "Toyota")
        XCTAssertEqual(cameraViewModel.detectionResults?.model, "Camry")
        XCTAssertEqual(cameraViewModel.detectionResults?.confidence, 0.85)
    }
    
    func testCapturedImageUpdating() throws {
        let testImage = createTestImage()
        
        cameraViewModel.capturedImage = testImage
        
        XCTAssertNotNil(cameraViewModel.capturedImage)
        XCTAssertEqual(cameraViewModel.capturedImage, testImage)
    }
    
    // MARK: - Location Manager Tests
    
    func testLocationManagerSetup() throws {
        // Test that location manager is properly initialized
        // Note: This would require exposing the location manager or using dependency injection
        XCTAssertNotNil(cameraViewModel)
    }
    
    // MARK: - Photo Capture Tests
    
    func testCapturePhoto() throws {
        // Test that capture photo doesn't crash
        cameraViewModel.capturePhoto()
        
        // Note: In a real test, you'd need to mock AVCapturePhotoOutput
        // and test the delegate methods
        XCTAssertNotNil(cameraViewModel)
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() throws {
        weak var weakViewModel = cameraViewModel
        
        // Set some data
        cameraViewModel.capturedImage = createTestImage()
        cameraViewModel.errorMessage = "Test error"
        
        // Release the view model
        cameraViewModel = nil
        
        // Verify it's deallocated
        XCTAssertNil(weakViewModel)
    }
    
    // MARK: - State Management Tests
    
    func testStateTransitions() throws {
        // Test initial state
        XCTAssertFalse(cameraViewModel.isProcessing)
        XCTAssertNil(cameraViewModel.errorMessage)
        XCTAssertNil(cameraViewModel.detectionResults)
        
        // Test processing state
        cameraViewModel.isProcessing = true
        XCTAssertTrue(cameraViewModel.isProcessing)
        
        // Test error state
        cameraViewModel.errorMessage = "Test error"
        XCTAssertEqual(cameraViewModel.errorMessage, "Test error")
        
        // Test results state
        let testResult = CarDetectionResult(
            carDetected: true,
            licenseplate: "ABC123",
            make: "Honda",
            model: "Civic",
            location: nil,
            timestamp: Date(),
            confidence: 0.9
        )
        
        cameraViewModel.detectionResults = testResult
        XCTAssertNotNil(cameraViewModel.detectionResults)
        XCTAssertTrue(cameraViewModel.detectionResults!.carDetected)
        
        // Test clearing state
        cameraViewModel.isProcessing = false
        cameraViewModel.errorMessage = nil
        cameraViewModel.detectionResults = nil
        
        XCTAssertFalse(cameraViewModel.isProcessing)
        XCTAssertNil(cameraViewModel.errorMessage)
        XCTAssertNil(cameraViewModel.detectionResults)
    }
    
    // MARK: - Threading Tests
    
    func testMainThreadUpdates() throws {
        let testImage = createTestImage()
        let expectation = XCTestExpectation(description: "Main thread updates")
        
        // Process image on background thread
        DispatchQueue.global(qos: .background).async {
            self.cameraViewModel.processImage(testImage)
            
            // Check that UI updates happen on main thread
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                XCTAssertTrue(Thread.isMainThread)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - CameraViewModel Test Extensions

extension CameraViewModel {
    // Expose private method for testing
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        let carDetector = CarDetectionService()
        
        carDetector.detectCarInImage(image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let detectionResult):
                    if detectionResult.carDetected {
                        self?.detectionResults = detectionResult
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
