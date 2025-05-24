
#import "FaceOverlay.h"

@implementation LineConnection

- (instancetype)initWithColor:(UIColor *)color lines:(Line *)lines count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _color = color;
        _lines = lines;
        _lineCount = count;
    }
    return self;
}

@end

@implementation FaceOverlay

- (instancetype)initWithDots:(NSArray<NSValue *> *)dots lineConnections:(NSArray<LineConnection *> *)connections {
    self = [super init];
    if (self) {
        _dots = dots;
        _lineConnections = connections;
    }
    return self;
}

@end
