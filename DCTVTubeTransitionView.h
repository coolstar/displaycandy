#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "DCTransitionView.h"

@interface DCTVTubeTransitionView : DCTransitionView {
    BOOL isLaunching;
    CFTimeInterval stepDuration;
    CATransform3D originalTransform;
    CATransform3D horizontalSquashTransform;
    CATransform3D horizontalExpandTransform;
    CATransform3D verticalSquashTransform;
}

@end
