#import "SpringBoard-Minimal.h"
#import "DCTypes.h"

@class SBApplication;

@protocol DCTransitionDelegate

@optional
- (void)displayCandyAnimationFinishedWithMode:(DCTransitionMode)mode app:(SBApplication *)app;

@end
