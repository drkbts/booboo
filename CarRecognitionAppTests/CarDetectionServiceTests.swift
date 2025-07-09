import XCTest
import Vision
import CoreLocation
@testable import CarRecognitionApp

final class CarDetectionServiceTests: XCTestCase {
    
    var carDetectionService: CarDetectionService!
    
    override func setUpWithError() throws {
        carDetectionService = CarDetectionService()
    }
    
    override func tearDownWithError() throws {
        carDetectionService = nil
    }
    
    // MARK: - License Plate Pattern Tests
    
    func testLicensePlatePatternRecognition() throws {
        let service = carDetectionService!
        
        // Test valid license plate patterns
        XCTAssertTrue(service.isLicensePlatePattern("ABC123"))
        XCTAssertTrue(service.isLicensePlatePattern("123ABC"))
        XCTAssertTrue(service.isLicensePlatePattern("AB1234"))
        XCTAssertTrue(service.isLicensePlatePattern("1234AB"))
        XCTAssertTrue(service.isLicensePlatePattern("ABCD123"))
        XCTAssertTrue(service.isLicensePlatePattern("A1B2C3"))
        
        // Test invalid patterns
        XCTAssertFalse(service.isLicensePlatePattern("AB"))
        XCTAssertFalse(service.isLicensePlatePattern("123"))
        XCTAssertFalse(service.isLicensePlatePattern("ABCDEFGH"))
        XCTAssertFalse(service.isLicensePlatePattern("12345678"))
        XCTAssertFalse(service.isLicensePlatePattern("A@B#C$"))
        XCTAssertFalse(service.isLicensePlatePattern(""))
    }
    
    func testLicensePlatePatternWithSpaces() throws {
        let service = carDetectionService!
        
        // Test patterns with spaces (should be handled)
        XCTAssertTrue(service.isLicensePlatePattern("ABC 123"))
        XCTAssertTrue(service.isLicensePlatePattern("AB 1234"))
        XCTAssertTrue(service.isLicensePlatePattern("A B C 1 2 3"))
    }
    
    func testLicensePlatePatternCaseInsensitive() throws {
        let service = carDetectionService!
        
        // Test case insensitivity
        XCTAssertTrue(service.isLicensePlatePattern("abc123"))
        XCTAssertTrue(service.isLicensePlatePattern("Abc123"))
        XCTAssertTrue(service.isLicensePlatePattern("ABC123"))
        XCTAssertTrue(service.isLicensePlatePattern("aBc123"))
    }
    
    // MARK: - Car Detection Tests
    
    func testCarDetectionWithValidImage() throws {
        let expectation = XCTestExpectation(description: "Car detection completes")
        
        // Create a test image (solid color for testing)
        let testImage = createTestImage(color: .blue, size: CGSize(width: 300, height: 200))
        
        carDetectionService.detectCarInImage(testImage) { result in
            switch result {
            case .success(let detectionResult):
                XCTAssertNotNil(detectionResult)
                XCTAssertEqual(detectionResult.timestamp.timeIntervalSinceNow, 0, accuracy: 1.0)
                XCTAssertGreaterThanOrEqual(detectionResult.confidence, 0.0)
                XCTAssertLessThanOrEqual(detectionResult.confidence, 1.0)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Car detection failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCarDetectionWithInvalidImage() throws {
        let expectation = XCTestExpectation(description: "Car detection handles invalid image")
        
        // Create an invalid image (1x1 pixel)
        let testImage = createTestImage(color: .clear, size: CGSize(width: 1, height: 1))
        
        carDetectionService.detectCarInImage(testImage) { result in
            switch result {
            case .success(let detectionResult):
                // Should still return a result, just with carDetected = false
                XCTAssertNotNil(detectionResult)
                expectation.fulfill()
            case .failure(_):
                // Failure is also acceptable for invalid images
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - CarDetectionResult Tests
    
    func testCarDetectionResultInitialization() throws {
        let timestamp = Date()
        let location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        
        let result = CarDetectionResult(
            carDetected: true,
            licenseplate: "ABC123",
            make: "Toyota",
            model: "Camry",
            location: location,
            timestamp: timestamp,
            confidence: 0.85
        )
        
        XCTAssertTrue(result.carDetected)
        XCTAssertEqual(result.licenseplate, "ABC123")
        XCTAssertEqual(result.make, "Toyota")
        XCTAssertEqual(result.model, "Camry")
        XCTAssertEqual(result.location, location)
        XCTAssertEqual(result.timestamp, timestamp)
        XCTAssertEqual(result.confidence, 0.85)
    }
    
    func testCarDetectionResultWithNilValues() throws {
        let timestamp = Date()
        
        let result = CarDetectionResult(
            carDetected: false,
            licenseplate: nil,
            make: nil,
            model: nil,
            location: nil,
            timestamp: timestamp,
            confidence: 0.0
        )
        
        XCTAssertFalse(result.carDetected)
        XCTAssertNil(result.licenseplate)
        XCTAssertNil(result.make)
        XCTAssertNil(result.model)
        XCTAssertNil(result.location)
        XCTAssertEqual(result.timestamp, timestamp)
        XCTAssertEqual(result.confidence, 0.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testCarDetectionErrorTypes() throws {
        let invalidImageError = CarDetectionError.invalidImage
        let noCarDetectedError = CarDetectionError.noCarDetected
        let noLicensePlateError = CarDetectionError.noLicensePlateVisible
        let processingError = CarDetectionError.processingError
        
        XCTAssertEqual(invalidImageError.localizedDescription, "Invalid image format")
        XCTAssertEqual(noCarDetectedError.localizedDescription, "No car detected in the image")
        XCTAssertEqual(noLicensePlateError.localizedDescription, "No license plate visible in the image")
        XCTAssertEqual(processingError.localizedDescription, "Error processing the image")
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - CarDetectionService Test Extensions

extension CarDetectionService {
    // Expose private method for testing
    func isLicensePlatePattern(_ text: String) -> Bool {
        let cleanText = text.replacingOccurrences(of: " ", with: "").uppercased()
        
        let patterns = [
            "^[A-Z0-9]{6,8}$",
            "^[A-Z]{1,3}[0-9]{3,4}$",
            "^[0-9]{3}[A-Z]{3}$",
        ]
        
        for pattern in patterns {
            if cleanText.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
}
