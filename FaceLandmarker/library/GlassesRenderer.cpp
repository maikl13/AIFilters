#include "GlassesRenderer.h"
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>
#include <stdlib.h>
#include "stb_image.h"
#include <cmath>

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
        "uniform mat4 modelMatrix;\n"
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

    printf("✅ Loaded texture: %dx%d\n", width, height);

    float aspect = (float)width / (float)height;
    float screenAspect = (float)screenWidth / (float)screenHeight;
    float finalAspect = aspect / screenAspect;

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
void GlassesRenderer::render(const HeadPoseData& pose, float centerX, float centerY, int backingWidth, int backingHeight) {
    glUseProgram(programId);


    // 🟩 أولًا: حول centerX, centerY لنسب (0-1)
    float normalizedX = centerX / (float)backingWidth;
    float normalizedY = centerY / (float)backingHeight;

    // 🟩 ثم إلى NDC (-1, 1) واضف عامل التصحيح
    float translationScaleX = 2.5f; // ابدأ بـ 1.5 كمثال للتصحيح
    float translationScaleY = 2.5f;

    normalizedX = (normalizedX * 2.0f - 1.0f) * translationScaleX;
    normalizedY = (1.0f - normalizedY * 2.0f) * translationScaleY;
    printf("🔎 Translation NDC (with scale): X=%.6f, Y=%.6f\n", normalizedX, normalizedY);

    // 🟩 مصفوفة modelMatrix (تدوير + تكبير + تحريك)

    float s = pose.scale/ ((float)backingWidth / 40);
    
  
    
    float cosYaw = cos(pose.yawAngle);
    float sinYaw = sin(pose.yawAngle);
    float cosPitch = cos(pose.pitchAngle);
    float sinPitch = sin(pose.pitchAngle);
    float cosRoll = cos(pose.rollAngle);
    float sinRoll = sin(pose.rollAngle);
    float rollMatrix[16] = {
        cosRoll, -sinRoll, 0, 0,
        sinRoll,  cosRoll, 0, 0,
        0,        0,       1, 0,
        0,        0,       0, 1
    };

    float yawMatrix[16] = {
        cosYaw,  0, sinYaw, 0,
        0,       1, 0,      0,
       -sinYaw, 0, cosYaw,  0,
        0,       0, 0,      1
    };

    float pitchMatrix[16] = {
        1, 0,        0,         0,
        0, cosPitch, -sinPitch, 0,
        0, sinPitch, cosPitch,  0,
        0, 0,        0,         1
    };

    float scaleMatrix[16] = {
        s, 0, 0, 0,
        0, s, 0, 0,
        0, 0, s, 0,
        0, 0, 0, 1
    };

    float translateMatrix[16] = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        normalizedX, normalizedY, 0, 1
    };

    // 🟩 دمج المصفوفات: T * Rz * Ry * Rx * S
    float temp1[16], temp2[16], temp3[16], modelMatrix[16];
    multiplyMatrix(rollMatrix, pitchMatrix, temp1);
    multiplyMatrix(temp1, yawMatrix, temp2);
    multiplyMatrix(temp2, scaleMatrix, temp3);
    multiplyMatrix(translateMatrix, temp3, modelMatrix);

    glUniformMatrix4fv(modelMatrixHandle, 1, GL_FALSE, modelMatrix);

    // 🔴 الرسم
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
        printf("✅ Rendered Texture w/ dynamic pose!\n");
    }
}

void GlassesRenderer::multiplyMatrix(const float* a, const float* b, float* result) {
    for (int row = 0; row < 4; ++row) {
        for (int col = 0; col < 4; ++col) {
            result[row * 4 + col] =
                a[row * 4 + 0] * b[0 * 4 + col] +
                a[row * 4 + 1] * b[1 * 4 + col] +
                a[row * 4 + 2] * b[2 * 4 + col] +
                a[row * 4 + 3] * b[3 * 4 + col];
        }
    }
}
