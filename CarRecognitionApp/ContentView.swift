import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if cameraViewModel.hasPermissions {
                    CameraView(viewModel: cameraViewModel)
                } else {
                    PermissionView(viewModel: cameraViewModel)
                }
            }
            .navigationTitle("Car Recognition")
        }
    }
}

struct PermissionView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Camera & Location Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("This app needs camera access to take photos and location access to record where photos were taken.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Grant Permissions") {
                viewModel.requestPermissions()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
