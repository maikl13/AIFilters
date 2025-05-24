import UIKit
import AVFoundation
import MediaPipeTasksVision

class CameraViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var previewView: UIView!
    
    private var overlayView: OverlayView!
    
    // MARK: - Camera & MediaPipe
    private lazy var cameraFeedService = CameraFeedService(previewView: previewView)
    private let faceLandmarkerQueue = DispatchQueue(label: "com.myapp.faceLandmarkerQueue", attributes: .concurrent)
    private var _faceLandmarkerService: FaceLandmarkerService?
    
    private var faceLandmarkerService: FaceLandmarkerService? {
        get { faceLandmarkerQueue.sync { _faceLandmarkerService } }
        set { faceLandmarkerQueue.async(flags: .barrier) { self._faceLandmarkerService = newValue } }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // تهيئة الكاميرا
        cameraFeedService.delegate = self
        
        // أضف الـ OverlayView الذي يحتوي OpenGL
        overlayView = OverlayView(frame: view.bounds)
        
  
        
        view.addSubview(overlayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeFaceLandmarkerService()
        cameraFeedService.startLiveCameraSession { status in
            if status == .failed {
                print("⚠️ تعذر بدء الكاميرا.")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraFeedService.stopSession()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        cameraFeedService.updateVideoPreviewLayer(toFrame: previewView.bounds)
    }
    
    // MARK: - MediaPipe
    private func initializeFaceLandmarkerService() {
        let modelPath = Bundle.main.path(forResource: "face_landmarker", ofType: "task")
        faceLandmarkerService = FaceLandmarkerService.liveStreamFaceLandmarkerService(
            modelPath: modelPath,
            numFaces: 1,
            minFaceDetectionConfidence: 0.5,
            minFacePresenceConfidence: 0.5,
            minTrackingConfidence: 0.5,
            liveStreamDelegate: self,
            delegate: InferenceConfigurationManager.sharedInstance.delegate
        )
    }
}

// MARK: - CameraFeedServiceDelegate
extension CameraViewController: CameraFeedServiceDelegate {
    func didOutput(sampleBuffer: CMSampleBuffer, orientation: UIImage.Orientation) {
        let currentTimeMs = Int(Date().timeIntervalSince1970 * 1000)
        faceLandmarkerService?.detectAsync(sampleBuffer: sampleBuffer, orientation: orientation, timeStamps: currentTimeMs)
    }
    
    func didEncounterSessionRuntimeError() {
        print("⚠️ حدث خطأ في تشغيل جلسة الكاميرا.")
    }
    
    func sessionWasInterrupted(canResumeManually resumeManually: Bool) {
        print("⚠️ الكاميرا متوقفة مؤقتًا.")
    }
    
    func sessionInterruptionEnded() {
        print("✅ الكاميرا عادت للعمل.")
    }
}

// MARK: - FaceLandmarkerServiceLiveStreamDelegate
extension CameraViewController: FaceLandmarkerServiceLiveStreamDelegate {
    func faceLandmarkerService(_ faceLandmarkerService: FaceLandmarkerService,
                               didFinishDetection result: ResultBundle?,
                               error: Error?) {
        guard let faceResult = result?.faceLandmarkerResults.first as? FaceLandmarkerResult,
              let landmarks = faceResult.faceLandmarks.first else { return }
        
        let points: [CGPoint] = landmarks.map { CGPoint(x: CGFloat($0.x), y: CGFloat($0.y)) }
        let nsValuePoints: [NSValue] = points.map { NSValue(cgPoint: $0) }
        
        // إرسال البيانات إلى OverlayView الذي داخله GLView
        DispatchQueue.main.async {
            self.overlayView.draw(
                OverlayView.faceOverlays(
                    fromLandmarks: [nsValuePoints],
                    imageSize: self.cameraFeedService.videoResolution,
                    overlayViewSize: self.overlayView.bounds.size,
                    imageContentMode: .scaleAspectFit,
                    orientation: .up
                )
            )
        }
    }
}
