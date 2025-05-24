
#import "GLView.h"
#import <QuartzCore/CAEAGLLayer.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "HeadPoseCalculator.h"

@interface GLView () {
    EAGLContext *_context;
    GLuint _framebuffer;
    GLuint _renderbuffer;
    GLint _backingWidth;
    GLint _backingHeight;

    GlassesRenderer renderer;
}
@end

@implementation GLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupGL];
    }
    return self;
}

- (void)setupGL {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking: @NO,
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };

    glGenFramebuffers(1, &_framebuffer);
    glGenRenderbuffers(1, &_renderbuffer);

    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

    renderer.setup();
    NSString *path = [[NSBundle mainBundle] pathForResource:@"glasses" ofType:@"png"];
    const char* imagePath = [path UTF8String];
    renderer.loadImageAsTexture(imagePath, _backingWidth, _backingHeight);
    


}

- (void)updatePoseWithLeftEye:(CGPoint)leftEye
                     rightEye:(CGPoint)rightEye
                         nose:(CGPoint)nose
                 glassesWidth:(float)glassesWidth {

    
    
    HeadPoseData pose = computeHeadPose(leftEye.x, leftEye.y, rightEye.x, rightEye.y, nose.x, nose.y, glassesWidth);

    glViewport(0, 0, _backingWidth, _backingHeight);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);

    float centerX = (leftEye.x + rightEye.x) / 2.0f;
    float centerY = (leftEye.y + rightEye.y) / 2.0f;

    renderer.render(pose, centerX, centerY);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    

}

- (void)layoutSubviews {
    [super layoutSubviews];
    [EAGLContext setCurrentContext:_context];
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
}

@end
