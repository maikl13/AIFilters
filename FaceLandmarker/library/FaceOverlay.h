
#import <UIKit/UIKit.h>

/// خط مستقيم
typedef struct {
    CGPoint from;
    CGPoint to;
} Line;

/// لون وخطوط
@interface LineConnection : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) Line *lines;
@property (nonatomic, assign) NSUInteger lineCount;
- (instancetype)initWithColor:(UIColor *)color lines:(Line *)lines count:(NSUInteger)count;
@end

/// Overlay بيانات الوجه
@interface FaceOverlay : NSObject
@property (nonatomic, strong) NSArray<NSValue *> *dots; // NSValue of CGPoint
@property (nonatomic, strong) NSArray<LineConnection *> *lineConnections;
- (instancetype)initWithDots:(NSArray<NSValue *> *)dots lineConnections:(NSArray<LineConnection *> *)connections;
@end
