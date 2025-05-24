import UIKit

/// خط مستقيم
struct Line {
  let from: CGPoint
  let to: CGPoint
}

/// خطوص توصيلية
struct LineConnection {
  let color: UIColor
  let lines: [Line]
}

/// Overlay يمثل بيانات الوجه
struct FaceOverlay {
  let dots: [CGPoint]
  let lineConnections: [LineConnection]
}
