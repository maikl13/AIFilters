
#ifndef HeadPoseCalculator_h
#define HeadPoseCalculator_h

struct HeadPoseData {
    float yawAngle;
    float pitchAngle;
    float rollAngle;
    float scale;
    float xOffset;
    float yOffset;
};

HeadPoseData computeHeadPose(float leftEyeX, float leftEyeY,
                             float rightEyeX, float rightEyeY,
                             float noseX, float noseY,
                             float glassesWidth);

#endif /* HeadPoseCalculator_h */
