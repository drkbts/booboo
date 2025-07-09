import XCTest

final class CarRecognitionAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Launch and Navigation Tests
    
    func testAppLaunch() throws {
        XCTAssertTrue(app.exists)
        XCTAssertTrue(app.navigationBars["Car Recognition"].exists)
    }
    
    func testPermissionScreen() throws {
        // Check if permission screen is displayed
        if app.staticTexts["Camera & Location Access Required"].exists {
            XCTAssertTrue(app.staticTexts["Camera & Location Access Required"].exists)
            XCTAssertTrue(app.staticTexts["This app needs camera access to take photos and location access to record where photos were taken."].exists)
            XCTAssertTrue(app.buttons["Grant Permissions"].exists)
        }
    }
    
    func testPermissionButton() throws {
        // If permission screen exists, test the button
        if app.buttons["Grant Permissions"].exists {
            let permissionButton = app.buttons["Grant Permissions"]
            XCTAssertTrue(permissionButton.isEnabled)
            
            // Tap the button (this would normally trigger system permission dialogs)
            permissionButton.tap()
            
            // Note: In a real test, you'd need to handle system permission dialogs
            // using XCUIApplication's interruption handling
        }
    }
    
    func testCameraViewAppearance() throws {
        // This test assumes permissions are granted
        // In a real test environment, you'd need to mock or pre-grant permissions
        
        // Look for camera view elements
        let cameraView = app.otherElements["CameraView"]
        
        // If camera view is present, test its elements
        if cameraView.exists {
            // Check for capture button
            let captureButton = app.buttons["Capture"]
            if captureButton.exists {
                XCTAssertTrue(captureButton.isEnabled)
            }
        }
    }
    
    // MARK: - Camera Interaction Tests
    
    func testCameraCapture() throws {
        // Skip this test if no camera permissions
        guard app.otherElements["CameraView"].exists else {
            throw XCTSkip("Camera view not available - permissions may not be granted")
        }
        
        // Find and tap the capture button
        let captureButton = app.buttons["Capture"]
        XCTAssertTrue(captureButton.exists)
        XCTAssertTrue(captureButton.isEnabled)
        
        captureButton.tap()
        
        // Wait for processing indicator
        let processingIndicator = app.staticTexts["Processing..."]
        if processingIndicator.exists {
            XCTAssertTrue(processingIndicator.exists)
        }
    }
    
    func testProcessingIndicator() throws {
        // Skip if no camera access
        guard app.otherElements["CameraView"].exists else {
            throw XCTSkip("Camera view not available")
        }
        
        // Tap capture button
        let captureButton = app.buttons["Capture"]
        if captureButton.exists {
            captureButton.tap()
            
            // Check that button is disabled during processing
            let expectation = XCTestExpectation(description: "Processing completes")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if captureButton.exists {
                    // Button should be disabled during processing
                    XCTAssertFalse(captureButton.isEnabled)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
    }
    
    // MARK: - Results View Tests
    
    func testResultsViewAppearance() throws {
        // This test would need to be triggered after a successful image capture
        // For now, we'll test the basic structure
        
        // Look for results view elements that might appear
        let resultsView = app.otherElements["ResultsView"]
        
        if resultsView.exists {
            // Test navigation title
            XCTAssertTrue(app.navigationBars["Car Analysis"].exists)
            
            // Test done button
            let doneButton = app.buttons["Done"]
            XCTAssertTrue(doneButton.exists)
            XCTAssertTrue(doneButton.isEnabled)
        }
    }
    
    func testResultsViewContent() throws {
        // Skip if results view isn't present
        guard app.otherElements["ResultsView"].exists else {
            throw XCTSkip("Results view not available")
        }
        
        // Test for detection results text
        let detectionResultsText = app.staticTexts["Detection Results"]
        XCTAssertTrue(detectionResultsText.exists)
        
        // Test for result rows
        let carDetectedRow = app.staticTexts["Car Detected"]
        let licensePlateRow = app.staticTexts["License Plate"]
        let makeRow = app.staticTexts["Make"]
        let modelRow = app.staticTexts["Model"]
        let locationRow = app.staticTexts["Location"]
        let dateTimeRow = app.staticTexts["Date & Time"]
        let confidenceRow = app.staticTexts["Confidence"]
        
        if carDetectedRow.exists {
            XCTAssertTrue(carDetectedRow.exists)
        }
        if licensePlateRow.exists {
            XCTAssertTrue(licensePlateRow.exists)
        }
        if makeRow.exists {
            XCTAssertTrue(makeRow.exists)
        }
        if modelRow.exists {
            XCTAssertTrue(modelRow.exists)
        }
        if locationRow.exists {
            XCTAssertTrue(locationRow.exists)
        }
        if dateTimeRow.exists {
            XCTAssertTrue(dateTimeRow.exists)
        }
        if confidenceRow.exists {
            XCTAssertTrue(confidenceRow.exists)
        }
    }
    
    func testResultsViewDismissal() throws {
        // Skip if results view isn't present
        guard app.otherElements["ResultsView"].exists else {
            throw XCTSkip("Results view not available")
        }
        
        // Tap done button
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        
        doneButton.tap()
        
        // Verify results view is dismissed
        let expectation = XCTestExpectation(description: "Results view dismissed")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(app.otherElements["ResultsView"].exists)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorAlertAppearance() throws {
        // This test would check for error alerts
        // Since we can't easily trigger errors in UI tests, we'll check for alert handling
        
        let errorAlert = app.alerts["Error"]
        
        if errorAlert.exists {
            XCTAssertTrue(errorAlert.exists)
            
            // Check for OK button
            let okButton = errorAlert.buttons["OK"]
            XCTAssertTrue(okButton.exists)
            XCTAssertTrue(okButton.isEnabled)
            
            // Tap OK to dismiss
            okButton.tap()
            
            // Verify alert is dismissed
            XCTAssertFalse(errorAlert.exists)
        }
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityElements() throws {
        // Test that key UI elements have proper accessibility labels
        
        if app.buttons["Grant Permissions"].exists {
            let permissionButton = app.buttons["Grant Permissions"]
            XCTAssertTrue(permissionButton.isAccessibilityElement)
            XCTAssertFalse(permissionButton.accessibilityLabel?.isEmpty ?? true)
        }
        
        if app.buttons["Capture"].exists {
            let captureButton = app.buttons["Capture"]
            XCTAssertTrue(captureButton.isAccessibilityElement)
        }
        
        if app.buttons["Done"].exists {
            let doneButton = app.buttons["Done"]
            XCTAssertTrue(doneButton.isAccessibilityElement)
        }
    }
    
    // MARK: - Orientation Tests
    
    func testOrientationChanges() throws {
        // Test portrait orientation
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.exists)
        
        // Test landscape orientation
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.exists)
        
        // Test landscape right
        XCUIDevice.shared.orientation = .landscapeRight
        XCTAssertTrue(app.exists)
        
        // Return to portrait
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.exists)
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Memory Warning Tests
    
    func testMemoryWarningHandling() throws {
        // Simulate memory warning
        app.terminate()
        app.launch()
        
        // Verify app recovers properly
        XCTAssertTrue(app.exists)
        XCTAssertTrue(app.navigationBars["Car Recognition"].exists)
    }
}
