#include "GlassesRenderer.h"
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>
#include <stdlib.h>
#include "stb_image.h"

// ملاحظة: لازم يكون متغير عادي (مش const) عشان نعدل الأبعاد بناءً على aspect
static GLfloat quadVertices[8] = {
    -0.5f, -0.5f,
     0.5f, -0.5f,
    -0.5f,  0.5f,
     0.5f,  0.5f
};

static const GLfloat quadTexCoords[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f
};

void GlassesRenderer::setup() {
    initShaders();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void GlassesRenderer::initShaders() {
    const char* vertexShaderSource =
        "attribute vec4 position;\n"
        "attribute vec2 texCoord;\n"
        "uniform mat4 modelMatrix;\n"  // 🟩 مصفوفة موحدة
        "varying vec2 v_TexCoord;\n"
        "void main() {\n"
        "  gl_Position = modelMatrix * position;\n"
        "  v_TexCoord = texCoord;\n"
        "}";
    const char* fragmentShaderSource =
        "precision mediump float;\n"
        "varying vec2 v_TexCoord;\n"
        "uniform sampler2D texture;\n"
        "void main() {\n"
        "  gl_FragColor = texture2D(texture, v_TexCoord);\n"
        "}";

    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);

    GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);

    programId = glCreateProgram();
    glAttachShader(programId, vertexShader);
    glAttachShader(programId, fragmentShader);
    glLinkProgram(programId);

    glUseProgram(programId);

    positionHandle = glGetAttribLocation(programId, "position");
    texCoordHandle = glGetAttribLocation(programId, "texCoord");
    textureHandle = glGetUniformLocation(programId, "texture");
    modelMatrixHandle = glGetUniformLocation(programId, "modelMatrix");
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    printf("✅ Shaders initialized\n");
}



void GlassesRenderer::loadImageAsTexture(const char* path, int screenWidth, int screenHeight) {
    printf("🔎 Loading texture from: %s\n", path);

    int width, height, channels;
    stbi_uc* data = stbi_load(path, &width, &height, &channels, STBI_rgb_alpha);
    if (!data) {
        printf("❌ Failed to load texture\n");
        return;
    }

    printf("✅ Loaded texture from file: %dx%d\n", width, height);

    // ✅ حساب aspect ratio للصورة
    float aspect = (float)width / (float)height;
    printf("📐 Image Aspect Ratio: %f\n", aspect);

    // ✅ حساب نسبة أبعاد الشاشة
    float screenAspect = (float)screenWidth / (float)screenHeight;
    printf("📱 Screen Aspect Ratio: %f\n", screenAspect);

    // ✅ final aspect للتصحيح
    float finalAspect = aspect / screenAspect;

    // ✅ تعديل الـ vertices بناءً على aspect المعدل
    quadVertices[0] = -0.5f * finalAspect; quadVertices[1] = -0.5f;
    quadVertices[2] =  0.5f * finalAspect; quadVertices[3] = -0.5f;
    quadVertices[4] = -0.5f * finalAspect; quadVertices[5] =  0.5f;
    quadVertices[6] =  0.5f * finalAspect; quadVertices[7] =  0.5f;

    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height,
                  0, GL_RGBA, GL_UNSIGNED_BYTE, data);

    stbi_image_free(data);

    printf("✅ Texture uploaded to GPU!\n");
}


void GlassesRenderer::render(const HeadPoseData& pose, float centerX, float centerY) {
    glUseProgram(programId);

    float s = 0.2f;  // حجم نص الشاشة
    float modelMatrix[16] = {
        s, 0, 0, 0,
        0, s, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    };
    glUniformMatrix4fv(modelMatrixHandle, 1, GL_FALSE, modelMatrix);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(textureHandle, 0);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glVertexAttribPointer(positionHandle, 2, GL_FLOAT, GL_FALSE, 0, quadVertices);
    glEnableVertexAttribArray(positionHandle);

    glVertexAttribPointer(texCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, quadTexCoords);
    glEnableVertexAttribArray(texCoordHandle);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(positionHandle);
    glDisableVertexAttribArray(texCoordHandle);

    

    
    GLenum err = glGetError();
    if (err != GL_NO_ERROR) {
        printf("⚠️ OpenGL Error: %x\n", err);
    } else {
        printf("✅ Rendered Texture!\n");
    }
}
