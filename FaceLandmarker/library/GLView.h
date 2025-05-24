
#import <UIKit/UIKit.h>
#import "GlassesRenderer.h"

@interface GLView : UIView
- (void)updatePoseWithLeftEye:(CGPoint)leftEye
                     rightEye:(CGPoint)rightEye
                         nose:(CGPoint)nose
                 glassesWidth:(float)glassesWidth;
@end
