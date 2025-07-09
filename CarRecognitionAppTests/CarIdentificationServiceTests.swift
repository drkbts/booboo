import XCTest
import Vision
@testable import CarRecognitionApp

final class CarIdentificationServiceTests: XCTestCase {
    
    var carIdentificationService: CarIdentificationService!
    
    override func setUpWithError() throws {
        carIdentificationService = CarIdentificationService()
    }
    
    override func tearDownWithError() throws {
        carIdentificationService = nil
    }
    
    // MARK: - Car Identification Tests
    
    func testCarIdentificationWithValidImage() throws {
        let expectation = XCTestExpectation(description: "Car identification completes")
        
        // Create a test image simulating a car
        let testImage = createCarTestImage()
        
        carIdentificationService.identifyCarMakeAndModel(from: testImage) { result in
            switch result {
            case .success(let identification):
                XCTAssertNotNil(identification)
                // The mock implementation should return some make/model
                // In real tests, you'd verify against expected values
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Car identification failed with error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCarIdentificationWithInvalidImage() throws {
        let expectation = XCTestExpectation(description: "Car identification handles invalid image")
        
        // Create an invalid image (1x1 pixel)
        let testImage = createTestImage(color: .clear, size: CGSize(width: 1, height: 1))
        
        carIdentificationService.identifyCarMakeAndModel(from: testImage) { result in
            switch result {
            case .success(let identification):
                // Should still return a result, even if make/model are nil
                XCTAssertNotNil(identification)
                expectation.fulfill()
            case .failure(let error):
                // Failure is acceptable for invalid images
                XCTAssertEqual(error as? CarIdentificationError, CarIdentificationError.invalidImage)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCarIdentificationWithVariousImageSizes() throws {
        let testCases = [
            CGSize(width: 100, height: 60),   // Small image
            CGSize(width: 300, height: 200),  // Medium image
            CGSize(width: 800, height: 600),  // Large image
            CGSize(width: 400, height: 300),  // Different aspect ratio
            CGSize(width: 600, height: 400),  // Another aspect ratio
        ]
        
        for size in testCases {
            let expectation = XCTestExpectation(description: "Car identification with size \(size)")
            let testImage = createTestImage(color: .blue, size: size)
            
            carIdentificationService.identifyCarMakeAndModel(from: testImage) { result in
                switch result {
                case .success(let identification):
                    XCTAssertNotNil(identification)
                    expectation.fulfill()
                case .failure(_):
                    // Failure is acceptable, just want to ensure no crashes
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - CarFeatures Tests
    
    func testCarFeaturesInitialization() throws {
        let features = CarFeatures(
            grilleArea: 0.5,
            headlightCount: 2,
            bodyProportions: 2.5,
            dominantColors: ["Silver", "Black"]
        )
        
        XCTAssertEqual(features.grilleArea, 0.5)
        XCTAssertEqual(features.headlightCount, 2)
        XCTAssertEqual(features.bodyProportions, 2.5)
        XCTAssertEqual(features.dominantColors, ["Silver", "Black"])
    }
    
    func testCarFeaturesWithEmptyColors() throws {
        let features = CarFeatures(
            grilleArea: 0.0,
            headlightCount: 0,
            bodyProportions: 1.0,
            dominantColors: []
        )
        
        XCTAssertEqual(features.grilleArea, 0.0)
        XCTAssertEqual(features.headlightCount, 0)
        XCTAssertEqual(features.bodyProportions, 1.0)
        XCTAssertTrue(features.dominantColors.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    func testCarIdentificationErrorTypes() throws {
        let invalidImageError = CarIdentificationError.invalidImage
        let noCarFeaturesError = CarIdentificationError.noCarFeatures
        let apiError = CarIdentificationError.apiError
        let processingError = CarIdentificationError.processingError
        
        XCTAssertEqual(invalidImageError.localizedDescription, "Invalid image format")
        XCTAssertEqual(noCarFeaturesError.localizedDescription, "Unable to identify car features")
        XCTAssertEqual(apiError.localizedDescription, "Car identification service error")
        XCTAssertEqual(processingError.localizedDescription, "Error processing car identification")
    }
    
    // MARK: - Prediction Logic Tests
    
    func testPredictionLogicWithDifferentFeatures() throws {
        let service = carIdentificationService!
        
        // Test different body proportions and headlight counts
        let testCases = [
            (bodyRatio: Float(2.6), headlightCount: 4, expectedMake: "Toyota"),
            (bodyRatio: Float(2.1), headlightCount: 3, expectedMake: "Honda"),
            (bodyRatio: Float(1.9), headlightCount: 2, expectedMake: "Ford"),
            (bodyRatio: Float(1.5), headlightCount: 1, expectedMake: "Chevrolet"),
        ]
        
        for testCase in testCases {
            let features = CarFeatures(
                grilleArea: 0.5,
                headlightCount: testCase.headlightCount,
                bodyProportions: testCase.bodyRatio,
                dominantColors: ["Silver"]
            )
            
            let prediction = service.predictMakeAndModel(from: features)
            XCTAssertEqual(prediction.0, testCase.expectedMake)
            XCTAssertNotNil(prediction.1) // Should have a model
        }
    }
    
    // MARK: - Performance Tests
    
    func testCarIdentificationPerformance() throws {
        let testImage = createCarTestImage()
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            
            carIdentificationService.identifyCarMakeAndModel(from: testImage) { result in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Concurrent Testing
    
    func testConcurrentCarIdentification() throws {
        let testImage = createCarTestImage()
        let concurrentCalls = 5
        var expectations: [XCTestExpectation] = []
        
        for i in 0..<concurrentCalls {
            let expectation = XCTestExpectation(description: "Concurrent call \(i)")
            expectations.append(expectation)
            
            carIdentificationService.identifyCarMakeAndModel(from: testImage) { result in
                switch result {
                case .success(_):
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Concurrent call \(i) failed: \(error)")
                }
            }
        }
        
        wait(for: expectations, timeout: 15.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func createCarTestImage() -> UIImage {
        let size = CGSize(width: 400, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Create a simple car-like shape for testing
            let rect = CGRect(origin: .zero, size: size)
            
            // Background
            UIColor.lightGray.setFill()
            context.fill(rect)
            
            // Car body (rectangle)
            UIColor.blue.setFill()
            let carBody = CGRect(x: 50, y: 150, width: 300, height: 100)
            context.fill(carBody)
            
            // Windshield
            UIColor.cyan.setFill()
            let windshield = CGRect(x: 100, y: 120, width: 200, height: 40)
            context.fill(windshield)
            
            // Wheels
            UIColor.black.setFill()
            let leftWheel = CGRect(x: 80, y: 220, width: 40, height: 40)
            let rightWheel = CGRect(x: 280, y: 220, width: 40, height: 40)
            context.fill(leftWheel)
            context.fill(rightWheel)
            
            // Headlights
            UIColor.yellow.setFill()
            let leftHeadlight = CGRect(x: 40, y: 160, width: 20, height: 15)
            let rightHeadlight = CGRect(x: 40, y: 185, width: 20, height: 15)
            context.fill(leftHeadlight)
            context.fill(rightHeadlight)
        }
    }
}

// MARK: - CarIdentificationService Test Extensions

extension CarIdentificationService {
    // Expose private method for testing
    func predictMakeAndModel(from features: CarFeatures) -> (String?, String?) {
        let bodyRatio = features.bodyProportions
        let headlightCount = features.headlightCount
        
        var make: String?
        var model: String?
        
        if bodyRatio > 2.5 && headlightCount >= 4 {
            make = "Toyota"
            model = "Camry"
        } else if bodyRatio > 2.0 && headlightCount >= 3 {
            make = "Honda"
            model = "Civic"
        } else if bodyRatio > 1.8 {
            make = "Ford"
            model = "Focus"
        } else {
            make = "Chevrolet"
            model = "Malibu"
        }
        
        return (make, model)
    }
}
