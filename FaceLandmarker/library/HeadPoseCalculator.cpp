
#include "HeadPoseCalculator.h"
#include <cmath>

HeadPoseData computeHeadPose(float leftEyeX, float leftEyeY,
                             float rightEyeX, float rightEyeY,
                             float noseX, float noseY,
                             float glassesWidth) {
    float dx = leftEyeX - rightEyeX;
    float dy = leftEyeY - rightEyeY;
    float angle = atan2f(dy, dx);
    float distance = hypotf(dx, dy);
    float scale = (distance / glassesWidth * 2.0f) * 0.8f;

    float centerX = (leftEyeX + rightEyeX) / 2.0f;
    float centerY = (leftEyeY + rightEyeY) / 2.0f;

    float yawAmount = noseX - centerX;
    float yawFactor = (1.0f / distance) * 4.0f;
    float yawAngle = yawAmount * yawFactor;

    float pitchAmount = centerY - noseY;
    float pitchFactor = (1.0f / distance) * 6.0f;
    float pitchAngle = pitchAmount * pitchFactor;

    float xOffset = yawAngle * 40.0f;
    float yOffset = pitchAngle * 10.0f;

    return {yawAngle, pitchAngle, angle, scale, xOffset, yOffset};
}
