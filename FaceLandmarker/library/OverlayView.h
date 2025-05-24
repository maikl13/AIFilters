
#import <UIKit/UIKit.h>
#import "FaceOverlay.h"

@interface OverlayView : UIView

// لتحديث عرض النظارات والـ 3D models باستخدام OpenGL
- (void)drawFaceOverlays:(NSArray<FaceOverlay *> *)faceOverlays;

+ (NSArray<FaceOverlay *> *)faceOverlaysFromLandmarks:(NSArray<NSArray<NSValue *> *> *)landmarks
                                      imageSize:(CGSize)imageSize
                                  overlayViewSize:(CGSize)overlayViewSize
                                 imageContentMode:(UIViewContentMode)imageContentMode
                                 orientation:(UIImageOrientation)orientation;



@end
