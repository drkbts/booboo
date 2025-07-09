import Foundation
import Vision
import UIKit
import CoreLocation

struct CarDetectionResult {
    let carDetected: Bool
    let licenseplate: String?
    let make: String?
    let model: String?
    let location: CLLocation?
    let timestamp: Date
    let confidence: Float
}

class CarDetectionService {
    
    func detectCarInImage(_ image: UIImage, completion: @escaping (Result<CarDetectionResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(CarDetectionError.invalidImage))
            return
        }
        
        let timestamp = Date()
        var detectionResult = CarDetectionResult(
            carDetected: false,
            licenseplate: nil,
            make: nil,
            model: nil,
            location: nil,
            timestamp: timestamp,
            confidence: 0.0
        )
        
        // Step 1: Detect cars using Vision framework
        self.detectObjectsInImage(cgImage) { objectResult in
            switch objectResult {
            case .success(let hasCarObjects):
                if hasCarObjects {
                    detectionResult = CarDetectionResult(
                        carDetected: true,
                        licenseplate: detectionResult.licenseplate,
                        make: detectionResult.make,
                        model: detectionResult.model,
                        location: detectionResult.location,
                        timestamp: timestamp,
                        confidence: 0.7
                    )
                    
                    // Step 2: Extract license plate text
                    self.extractLicensePlateText(from: cgImage) { plateResult in
                        var plateText: String?
                        if case .success(let text) = plateResult {
                            plateText = text
                        }
                        
                        // Step 3: Identify car make and model
                        let carIdentificationService = CarIdentificationService()
                        carIdentificationService.identifyCarMakeAndModel(from: image) { identificationResult in
                            var make: String?
                            var model: String?
                            
                            if case .success(let identification) = identificationResult {
                                make = identification.make
                                model = identification.model
                            }
                            
                            let finalResult = CarDetectionResult(
                                carDetected: true,
                                licenseplate: plateText,
                                make: make,
                                model: model,
                                location: detectionResult.location,
                                timestamp: timestamp,
                                confidence: 0.8
                            )
                            completion(.success(finalResult))
                        }
                    }
                } else {
                    completion(.success(detectionResult))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func detectObjectsInImage(_ cgImage: CGImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        let request = VNDetectRectanglesRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Look for rectangular objects that might be cars
            let rectangles = request.results as? [VNRectangleObservation] ?? []
            
            // Simple heuristic: if we find multiple rectangles of reasonable size, assume it's a car
            let carLikeRectangles = rectangles.filter { rectangle in
                let area = rectangle.boundingBox.width * rectangle.boundingBox.height
                return area > 0.1 && area < 0.8 && rectangle.confidence > 0.5
            }
            
            completion(.success(carLikeRectangles.count > 0))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    private func extractLicensePlateText(from cgImage: CGImage, completion: @escaping (Result<String?, Error>) -> Void) {
        let textRequest = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                
                let text = topCandidate.string
                
                // Simple license plate pattern matching
                if self.isLicensePlatePattern(text) {
                    completion(.success(text))
                    return
                }
            }
            
            completion(.success(nil))
        }
        
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            completion(.failure(error))
        }
    }
    
    private func isLicensePlatePattern(_ text: String) -> Bool {
        let cleanText = text.replacingOccurrences(of: " ", with: "").uppercased()
        
        // US license plate patterns (simplified)
        let patterns = [
            "^[A-Z0-9]{6,8}$",  // Generic 6-8 alphanumeric
            "^[A-Z]{1,3}[0-9]{3,4}$",  // 1-3 letters followed by 3-4 numbers
            "^[0-9]{3}[A-Z]{3}$",  // 3 numbers followed by 3 letters
        ]
        
        for pattern in patterns {
            if cleanText.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
}

enum CarDetectionError: Error {
    case invalidImage
    case noCarDetected
    case noLicensePlateVisible
    case processingError
}

extension CarDetectionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .noCarDetected:
            return "No car detected in the image"
        case .noLicensePlateVisible:
            return "No license plate visible in the image"
        case .processingError:
            return "Error processing the image"
        }
    }
}
