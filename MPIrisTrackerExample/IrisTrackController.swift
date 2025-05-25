import SwiftUI
import Resolver
import AVFoundation
import CoreImage
import CoreGraphics

public class IrisTrackController: ObservableObject {
    @Published var irisLandmarks = [MPLandmark]()
    @Published var faceMesh = [MPLandmark]()
    @Published var image: CGImage?
    @Published var annotatedImage: CGImage?

    private let context = CIContext()
    private var glassesImage: CIImage?

    init() {
        if let url = Bundle.main.url(forResource: "glasses", withExtension: "png"),
           let ciImage = CIImage(contentsOf: url) {
            self.glassesImage = ciImage
        } else {
            print("❌ لم يتم العثور على صورة النظارة")
        }
    }

    public func composeGlassesImage(on baseImage: CGImage) {
        guard faceMesh.count > 263 else {
            print("❌ عدد نقاط faceMesh غير كافٍ")
            return
        }
        guard let glasses = glassesImage else {
            print("❌ صورة النظارة غير محملة")
            return
        }
        DispatchQueue.main.async {
            self.annotatedImage = baseImage
        }
        
        return ;
        let ciBase = CIImage(cgImage: baseImage)

        let imageWidth = CGFloat(baseImage.width)
        let imageHeight = CGFloat(baseImage.height)

        // نقاط العين بعد تحويلها من نسبة مئوية إلى بكسل، وعكس محور y
        let rightEye = faceMesh[33]
        let leftEye = faceMesh[263]

        let rightX = CGFloat(rightEye.x) * imageWidth
        let rightY = imageHeight - CGFloat(rightEye.y) * imageHeight

        let leftX = CGFloat(leftEye.x) * imageWidth
        let leftY = imageHeight - CGFloat(leftEye.y) * imageHeight

        let dx = leftX - rightX
        let dy = leftY - rightY
        let angle = atan2(dy, dx)
        let distance = hypot(dx, dy)

        // مقياس النظارة بناءً على المسافة بين العينين
        let scale =  (distance / glasses.extent.width * 2.0) * 0.8
  
        let centerX = (leftX + rightX) / 2
        let centerY = (leftY + rightY) / 2

        let transform = CGAffineTransform.identity
            .translatedBy(x: centerX, y: centerY)
            .rotated(by: angle)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -glasses.extent.width / 2, y: -glasses.extent.height / 2)

        let transformedGlasses = glasses.transformed(by: transform)

        let output = transformedGlasses.composited(over: ciBase)

        
        if let cgFinal = context.createCGImage(output, from: output.extent) {
            DispatchQueue.main.async {
                self.annotatedImage = cgFinal
            }
        } else {
            print("❌ فشل في إنشاء annotated image")
        }
    }


    public static func imageFromSampleBuffer(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let imageRect = CGRect(x: 0, y: 0,
                               width: CVPixelBufferGetWidth(pixelBuffer),
                               height: CVPixelBufferGetHeight(pixelBuffer))
        let context = CIContext()
        return context.createCGImage(ciImage, from: imageRect)
    }
}
