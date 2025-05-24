#import "OverlayView.h"
#import "GLView.h"

@interface OverlayView ()
@property (nonatomic, strong) GLView *glView;
@end

@implementation OverlayView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _glView = [[GLView alloc] initWithFrame:self.bounds];
    [self addSubview:_glView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.glView.frame = self.bounds;
}

- (void)drawFaceOverlays:(NSArray<FaceOverlay *> *)faceOverlays {
  // استخدم أول وجه فقط للتجربة
  if (faceOverlays.count == 0) return;
  
  FaceOverlay *faceOverlay = faceOverlays.firstObject;
  if (faceOverlay.dots.count > 263) {
    CGPoint leftEye = [faceOverlay.dots[263] CGPointValue];
    CGPoint rightEye = [faceOverlay.dots[33] CGPointValue];
    CGPoint nose = [faceOverlay.dots[168] CGPointValue];
    // عرض النظارة بالرندر ثلاثي الأبعاد
    [self.glView updatePoseWithLeftEye:leftEye
                              rightEye:rightEye
                                  nose:nose
                          glassesWidth:100]; // حجم افتراضي، يمكن تغييره حسب صورتك
  }
    
    NSLog(@"✨ Received face overlays: %lu", (unsigned long)faceOverlays.count);
}

+ (NSArray<FaceOverlay *> *)faceOverlaysFromLandmarks:(NSArray<NSArray<NSValue *> *> *)landmarks
                                      imageSize:(CGSize)imageSize
                                  overlayViewSize:(CGSize)overlayViewSize
                                 imageContentMode:(UIViewContentMode)imageContentMode
                                 orientation:(UIImageOrientation)orientation {

    // هنا من الكود القديم (faceOverlays في Swift) ➜ كتابته بالـ Objective-C++
    NSMutableArray<FaceOverlay *> *overlays = [NSMutableArray array];
    
    for (NSArray<NSValue *> *faceLandmarks in landmarks) {
        // احسب التحويلات بناء على orientation
        NSMutableArray<NSValue *> *dots = [NSMutableArray array];
        for (NSValue *pointValue in faceLandmarks) {
            CGPoint point = [pointValue CGPointValue];
            // افترض مثلًا:
            [dots addObject:[NSValue valueWithCGPoint:point]];
        }
        
        // افترض لا يوجد خطوط حالياً:
        NSArray<LineConnection *> *connections = @[];
        
        FaceOverlay *overlay = [[FaceOverlay alloc] initWithDots:dots lineConnections:connections];
        [overlays addObject:overlay];
    }
    
    return overlays;
}

@end
