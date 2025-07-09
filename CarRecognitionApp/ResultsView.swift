import SwiftUI
import CoreLocation

struct ResultsView: View {
    let results: CarDetectionResult
    let image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image with overlay
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    
                    // Results card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detection Results")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ResultRow(
                            icon: "car.fill",
                            title: "Car Detected",
                            value: results.carDetected ? "Yes" : "No",
                            color: results.carDetected ? .green : .red
                        )
                        
                        if let licenseplate = results.licenseplate {
                            ResultRow(
                                icon: "rectangle.and.text.magnifyingglass",
                                title: "License Plate",
                                value: licenseplate,
                                color: .blue
                            )
                        } else {
                            ResultRow(
                                icon: "rectangle.and.text.magnifyingglass",
                                title: "License Plate",
                                value: "Not visible",
                                color: .orange
                            )
                        }
                        
                        if let make = results.make {
                            ResultRow(
                                icon: "car.2.fill",
                                title: "Make",
                                value: make,
                                color: .purple
                            )
                        } else {
                            ResultRow(
                                icon: "car.2.fill",
                                title: "Make",
                                value: "Unknown",
                                color: .gray
                            )
                        }
                        
                        if let model = results.model {
                            ResultRow(
                                icon: "car.side.fill",
                                title: "Model",
                                value: model,
                                color: .purple
                            )
                        } else {
                            ResultRow(
                                icon: "car.side.fill",
                                title: "Model",
                                value: "Unknown",
                                color: .gray
                            )
                        }
                        
                        // Location
                        if let location = results.location {
                            ResultRow(
                                icon: "location.fill",
                                title: "Location",
                                value: formatLocation(location),
                                color: .green
                            )
                        } else {
                            ResultRow(
                                icon: "location.fill",
                                title: "Location",
                                value: "Unknown",
                                color: .gray
                            )
                        }
                        
                        // Timestamp
                        ResultRow(
                            icon: "clock.fill",
                            title: "Date & Time",
                            value: formatTimestamp(results.timestamp),
                            color: .blue
                        )
                        
                        // Confidence
                        ResultRow(
                            icon: "gauge.high",
                            title: "Confidence",
                            value: "\(Int(results.confidence * 100))%",
                            color: confidenceColor(results.confidence)
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Car Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatLocation(_ location: CLLocation) -> String {
        let formatter = CLGeocoder()
        return String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
    }
    
    private func formatTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    private func confidenceColor(_ confidence: Float) -> Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ResultRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ResultsView(
        results: CarDetectionResult(
            carDetected: true,
            licenseplate: "ABC123",
            make: "Toyota",
            model: "Camry",
            location: CLLocation(latitude: 37.7749, longitude: -122.4194),
            timestamp: Date(),
            confidence: 0.85
        ),
        image: nil
    )
}
