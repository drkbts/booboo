# Car Recognition App

A comprehensive iOS application built with Swift and SwiftUI for automated car detection and license plate recognition. This app captures photos of vehicles and provides detailed analysis including license plate text, car make/model identification, location data, and timestamp information.

## Purpose

This application is designed to automatically identify and catalog vehicle information from photos. Key use cases include:

- **Parking Violation Documentation** - Record parking violations with complete vehicle details
- **Vehicle Inventory Management** - Catalog cars in lots or dealerships
- **Security and Access Control** - Monitor vehicle access to restricted areas
- **Fleet Management** - Track and identify company vehicles
- **Personal Use** - Document car details for insurance or personal records

## Features

### Core Functionality
- **Real-time Camera Interface** - Live camera preview with intuitive capture controls
- **Car Detection** - Automated detection of vehicles in captured images
- **License Plate Recognition** - OCR-based text extraction from license plates
- **Vehicle Identification** - Make and model identification (extensible with ML models)
- **Location Services** - GPS coordinates captured with each photo
- **Timestamp Recording** - Precise date and time documentation
- **Results Display** - Clean, organized presentation of all detected information

### Technical Features
- **Privacy-First Design** - All processing done locally on device
- **Offline Capability** - No internet connection required for core functionality
- **Error Handling** - Comprehensive error detection and user feedback
- **Accessibility Support** - Full accessibility compliance
- **Performance Optimized** - Efficient image processing and memory management

## Architecture

The application follows a clean, modular architecture using modern iOS development patterns:

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                        │
├─────────────────────────────────────────────────────────────┤
│  ContentView  │  CameraView  │  ResultsView  │ PermissionView │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      View Models                            │
├─────────────────────────────────────────────────────────────┤
│              CameraViewModel (ObservableObject)            │
│        • Camera session management                          │
│        • Permission handling                                │
│        • Image processing coordination                      │
│        • State management                                   │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
├─────────────────────────────────────────────────────────────┤
│  CarDetectionService  │  CarIdentificationService          │
│  • Vision framework   │  • ML model integration            │
│  • OCR processing     │  • Feature extraction              │
│  • Pattern matching   │  • Make/model prediction           │
└─────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    System Frameworks                        │
├─────────────────────────────────────────────────────────────┤
│  AVFoundation  │  Vision  │  CoreLocation  │  CoreML        │
│  • Camera      │  • OCR   │  • GPS        │  • ML Models   │
│  • Photo       │  • Detection              │  • Inference   │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **SwiftUI Views**
- **ContentView**: Root view with navigation and permission handling
- **CameraView**: Real-time camera interface with capture controls
- **ResultsView**: Displays detection results with visual overlay
- **PermissionView**: Handles camera and location permission requests

#### 2. **View Models**
- **CameraViewModel**: 
  - Manages camera session lifecycle
  - Handles permission requests and status
  - Coordinates image processing pipeline
  - Maintains application state (ObservableObject pattern)

#### 3. **Service Layer**
- **CarDetectionService**:
  - Integrates Vision framework for object detection
  - Implements OCR for license plate text extraction
  - Pattern matching for license plate validation
  - Coordinates overall detection pipeline

- **CarIdentificationService**:
  - Analyzes car features for make/model identification
  - Extensible for Core ML model integration
  - Provides prediction confidence scoring

#### 4. **Data Models**
- **CarDetectionResult**: Comprehensive result structure containing:
  - Car detection status
  - License plate text
  - Make and model information
  - Location data
  - Timestamp
  - Confidence scores

### Technology Stack

#### **Core Frameworks**
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for state management
- **AVFoundation** - Camera and media processing
- **Vision** - Computer vision and OCR capabilities
- **Core Location** - GPS and location services
- **Core ML** - Machine learning model integration (extensible)

#### **Design Patterns**
- **MVVM (Model-View-ViewModel)** - Clean separation of concerns
- **Observer Pattern** - State management with ObservableObject
- **Delegate Pattern** - Camera and location callbacks
- **Service Layer** - Business logic encapsulation
- **Dependency Injection** - Testable service architecture

#### **Testing Strategy**
- **Unit Tests** - Comprehensive service layer testing
- **UI Tests** - End-to-end user interaction testing
- **Mock Services** - Isolated testing with mock objects
- **Performance Tests** - Memory and processing optimization
- **Accessibility Tests** - Compliance verification

### File Structure

```
CarRecognitionApp/
├── CarRecognitionApp.swift          # App entry point
├── ContentView.swift                # Root view controller
├── CameraView.swift                 # Camera interface
├── CameraViewModel.swift            # Camera logic and state
├── ResultsView.swift                # Results display
├── CarDetectionService.swift        # Detection and OCR
├── CarIdentificationService.swift   # Vehicle identification
├── Info.plist                       # App configuration
└── Project.pbxproj                  # Xcode project file

CarRecognitionAppTests/
├── CarDetectionServiceTests.swift   # Detection service tests
├── CarIdentificationServiceTests.swift # ID service tests
├── CameraViewModelTests.swift       # ViewModel tests
└── MockServices.swift              # Test utilities

CarRecognitionAppUITests/
├── CarRecognitionAppUITests.swift   # UI interaction tests
└── CarRecognitionAppUITestsLaunchTests.swift # Launch tests
```

## Installation & Setup

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+
- Physical iOS device (camera required)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/drkbts/booboo.git
   cd booboo
   ```

2. **Open in Xcode**
   ```bash
   open CarRecognitionApp.xcodeproj
   ```

3. **Configure signing**
   - Select your development team in project settings
   - Update bundle identifier if needed

4. **Run on device**
   - Connect iOS device via USB
   - Select device in Xcode
   - Build and run (⌘R)

### Permissions
The app requires the following permissions:
- **Camera Access** - For capturing vehicle photos
- **Location Access** - For GPS coordinates (when in use only)

## Usage

1. **Launch the app** and grant camera/location permissions
2. **Point camera at vehicle** ensuring license plate is visible
3. **Tap capture button** to take photo
4. **Wait for processing** - AI analyzes the image
5. **View results** - License plate, make/model, location, and timestamp
6. **Review and save** detection results

## Development & Testing

### Running Tests
```bash
# Unit tests
xcodebuild test -scheme CarRecognitionApp -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme CarRecognitionAppUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Coverage
Run tests with coverage enabled in Xcode to view detailed coverage reports.

## Extensibility

### Adding ML Models
The architecture supports easy integration of Core ML models:

1. Add `.mlmodel` file to project
2. Update `CarIdentificationService` to use VNCoreMLRequest
3. Implement model-specific preprocessing
4. Update confidence scoring logic

### Custom License Plate Patterns
Extend license plate recognition for different regions:

1. Add new regex patterns to `CarDetectionService`
2. Implement region-specific validation
3. Update UI to show region information

### API Integration
For cloud-based vehicle identification:

1. Create API service layer
2. Implement network request handling
3. Add offline/online mode switching
4. Handle API rate limiting and errors

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues:
- Open an issue on GitHub
- Contact the development team
- Review the documentation

---

**Note**: This application processes all data locally for privacy. No image data is transmitted to external servers.
