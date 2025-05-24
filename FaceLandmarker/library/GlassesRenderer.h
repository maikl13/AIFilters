#ifndef GlassesRenderer_h
#define GlassesRenderer_h

#include <OpenGLES/ES2/gl.h>
#include "HeadPoseCalculator.h"

class GlassesRenderer {
public:
    void setup();
    void render(const HeadPoseData& pose, float centerX, float centerY);
    void loadImageAsTexture(const char* path, int screenWidth, int screenHeight);

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
