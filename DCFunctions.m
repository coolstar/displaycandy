#import "SpringBoard-Minimal.h"
#import <UIKit/UIKit.h>
#include <GraphicsServices/GraphicsServices.h>

#include "DCFunctions.h"

CGAffineTransform DCRotationTransformForCurrentOrientation()
{
    switch ([[UIApplication sharedApplication] activeInterfaceOrientation]) {
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(M_PI_2);
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(-M_PI_2);
        default:
            return CGAffineTransformIdentity;
    }
}
