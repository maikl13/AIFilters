#ifndef GlassesRenderer_h
#define GlassesRenderer_h

#include <OpenGLES/ES2/gl.h>
#include "HeadPoseCalculator.h"

class GlassesRenderer {
public:
    void setup();
    void render(const HeadPoseData& pose, float centerX, float centerY, int backingWidth, int backingHeight);
    void loadImageAsTexture(const char* path, int screenWidth, int screenHeight);
    void multiplyMatrix(const float* a, const float* b, float* result);
private:
    GLuint textureId;
    GLuint programId;

    GLuint positionHandle;
    GLuint texCoordHandle;
    GLuint mvpMatrixHandle;
    GLuint textureHandle;
    GLint modelMatrixHandle;
    void initShaders();


};

#endif /* GlassesRenderer_h */
