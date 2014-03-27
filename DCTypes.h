#ifndef DC_TYPES_H
#define DC_TYPES_H

typedef enum DCTransition {
    DCTransitionDefault,
    DCTransitionCube,
    DCTransitionFlip,
    DCTransitionPageCurl,
    DCTransitionPageUncurl,
    DCTransitionRipple,
    DCTransitionSuck,
    DCTransitionTVTube,
    DCTransitionFade,
    DCTransitionCover,
    DCTransitionReveal,
    DCTransitionPush,
    DCTransitionCameraIris,
    DCTransitionSwing,
	DCTransitionZoomFromIcon,
    DCTransitionRandom = 100
} DCTransition;

typedef enum DCTransitionMode {
    DCTransitionModeLaunch,
    DCTransitionModeSuspend,
    DCTransitionModeSwitch
} DCTransitionMode;

typedef enum DCTransitionDirection {
    DCTransitionDirectionLeft,
    DCTransitionDirectionRight,
    DCTransitionDirectionUp,
    DCTransitionDirectionDown
} DCTransitionDirection;

#endif // DC_TYPES_H
