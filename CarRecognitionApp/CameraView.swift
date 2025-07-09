import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    @State private var showingResults = false
    
    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.getCaptureSession())
                .ignoresSafeArea()
                .onAppear {
                    viewModel.startCamera()
                }
                .onDisappear {
                    viewModel.stopCamera()
                }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .disabled(viewModel.isProcessing)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            
            if viewModel.isProcessing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Processing...")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(.top)
                }
            }
        }
        .sheet(isPresented: $showingResults) {
            if let results = viewModel.detectionResults {
                ResultsView(results: results, image: viewModel.capturedImage)
            }
        }
        .onChange(of: viewModel.detectionResults) { _ in
            if viewModel.detectionResults != nil {
                showingResults = true
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        if let session = session {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.frame
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.frame
        }
    }
}

#Preview {
    CameraView(viewModel: CameraViewModel())
}
