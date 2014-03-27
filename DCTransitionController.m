#import "SpringBoard-Minimal.h"

#import "DCTypes.h"
#import "DCTransitionController.h"
#import "DCBuiltInTransitionView.h"
#import "DCCoverTransitionView.h"
#import "DCRevealTransitionView.h"
#import "DCPushTransitionView.h"
#import "DCTVTubeTransitionView.h"
#import "DCSwingTransitionView.h"
#import "DCZoomTransitionView.h"
#import "DCSettings.h"

#include "DCFunctions.h"

@interface DCTransitionController ()

- (CGRect)transitionViewFrame;
- (CGAffineTransform)transitionViewTransform;
- (Class)classForCustomTransition:(NSInteger)transition;
- (BOOL)transitionIsBuiltIn:(NSString *)transition;
- (NSString *)transitionTypeForValue:(NSInteger)value;

@end

@implementation DCTransitionController

- (DCTransitionController *)init
{
    self = [super init];

    if (self) {
        // Set up the container view.
        _view = [[UIView alloc] initWithFrame:[self transitionViewFrame]];
        [_view setBackgroundColor:[UIColor blackColor]];
        [_view setOpaque:YES];
    }

    return self;
}

- (void)dealloc
{
    [_application release];
    [_view release];
    [_transitionView release];
    [_fromView release];
    [_toView release];

    [super dealloc];
}

- (void)beginTransition:(NSInteger)transition
{
    // Rotate the container view depending on the orientation.
    CGAffineTransform rotationTransform = [self transitionViewTransform];
    [[self view] setTransform:rotationTransform];
    [[self view] setCenter:[[[self view] superview] center]];

    // Set the animation type.
    NSString *animationType = [self transitionTypeForValue:transition];

    if ([self transitionIsBuiltIn:animationType]) {
        _transitionView = [[DCBuiltInTransitionView alloc] initWithFrame:[[self view] bounds]];
        [(DCBuiltInTransitionView *)_transitionView setType:animationType];
    } else {
        Class TransitionViewClass = [self classForCustomTransition:transition];
        _transitionView = [[TransitionViewClass alloc] initWithFrame:[[self view] bounds]];
    }

    // Set the animation direction.
    DCTransitionDirection direction = [[DCSettings sharedSettings] directionForMode:[self mode]];

    // More setup.
    [_transitionView setOpaque:YES];
    [_transitionView setFromView:[self fromView]];
    [_transitionView setToView:[self toView]];

    [_transitionView setDelegate:self];
	[_transitionView setApplicationIdentifier:[[self application] displayIdentifier]];
    [_transitionView setDirection:direction];
    [_transitionView setMode:[self mode]];

    [[self view] addSubview:_transitionView];

    // Flush any changes to the view hierarchy
    [CATransaction flush];

    // Start the animation
    CGFloat duration = [[DCSettings sharedSettings] durationForMode:[self mode]];
    [_transitionView animateWithDuration:duration];
}

- (void)endTransition
{
    [_transitionView removeFromSuperview];
    [[_transitionView layer] removeAllAnimations];

    for (UIView *subview in [_transitionView subviews]) {
        [[subview layer] removeAllAnimations];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [[self delegate] displayCandyAnimationFinishedWithMode:[self mode] app:[self application]];
}

- (CGRect)transitionViewFrame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];

    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        return CGRectMake(screenBounds.origin.x, screenBounds.origin.y, screenBounds.size.height, screenBounds.size.width);
    } else {
        return screenBounds;
    }
}

- (CGAffineTransform)transitionViewTransform
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] activeInterfaceOrientation];

    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return CGAffineTransformIdentity;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(M_PI);
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-M_PI_2);
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(M_PI_2);
        default:
            return CGAffineTransformIdentity;

    }
}

- (Class)classForCustomTransition:(NSInteger)transition
{
    switch (transition) {
        case DCTransitionCover:
            return [DCCoverTransitionView class];
        case DCTransitionReveal:
            return [DCRevealTransitionView class];
        case DCTransitionPush:
            return [DCPushTransitionView class];
        case DCTransitionTVTube:
            return [DCTVTubeTransitionView class];
        case DCTransitionSwing:
            return [DCSwingTransitionView class];
		case DCTransitionZoomFromIcon:
            return [DCZoomTransitionView class];
        default:
            return nil;
    }
}

- (BOOL)transitionIsBuiltIn:(NSString *)transition
{
    NSArray *builtInTransitions = [[NSArray alloc] initWithObjects:@"cube", @"oglFlip", @"pageCurl", @"pageUnCurl", @"rippleEffect", @"suckEffect", @"fade", @"cameraIris", nil];
    BOOL isBuiltIn = [builtInTransitions containsObject:transition];
    [builtInTransitions release];

    return isBuiltIn;
}

- (NSString *)transitionTypeForValue:(NSInteger)value
{
    switch (value) {
        case 1:
            return @"cube";
        case 2:
            return @"oglFlip";
        case 3:
            return @"pageCurl";
        case 4:
            return @"pageUnCurl";
        case 5:
            return @"rippleEffect";
        case 6:
            return @"suckEffect";
        case 8:
            return @"fade";
       case 12:
            return @"cameraIris";
       default:
            return nil;
    }
}

@end
