#import <objc/runtime.h>
#import <GraphicsServices/GraphicsServices.h>
#import "SpringBoard-Minimal.h"
#import "DCAppToAppWrapperView.h"
#import "DCTransitionController.h"
#import "DCSettings.h"

#include "DCFunctions.h"

@interface SBAppToAppTransitionView (iOS6)
- (void)_animationBegan;
- (void)_animationEnded;
- (void)_notifyDelegateAnimationBeganWithDuration:(double)arg1 delay:(double)arg2;
- (void)_notifyDelegateThatAnimationIsDone;
@end

static char kTransitionKey;
static char kTransitionControllerKey;

%subclass DCAppToAppWrapperView : SBAppToAppTransitionView

- (id)initWithFrame:(CGRect)frame
{
    self = %orig;

    if (self) {
        // Create the transition view.
        DCTransitionController *transitionController = [[DCTransitionController alloc] init];
        [transitionController setDelegate:self];
        [transitionController setApplication:[self toApp]];
        [transitionController setMode:DCTransitionModeSwitch];

        [self addSubview:[transitionController view]];

        objc_setAssociatedObject(self, &kTransitionControllerKey, transitionController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);        
        [transitionController release];
    }

    return self;
}

%new
- (DCTransition)transition
{
	return [objc_getAssociatedObject(self, &kTransitionKey) intValue];
}

%new
- (void)setTransition:(DCTransition)transition
{
	objc_setAssociatedObject(self, &kTransitionKey, @(transition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);	
}

- (void)setFromView:(UIView *)fromView
{
    %orig;

    // Rotate the view depending on the orientation.
    CGAffineTransform rotationTransform = DCRotationTransformForCurrentOrientation();
    [fromView setTransform:rotationTransform];

    [fromView setBackgroundColor:[UIColor blackColor]];    

    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kTransitionControllerKey);    
    [transitionController setFromView:fromView];
}

- (void)setToView:(UIView *)toView
{
    %orig;
    
    // Rotate the view depending on the orientation.
    CGAffineTransform rotationTransform = DCRotationTransformForCurrentOrientation();
    [toView setTransform:rotationTransform];

    [toView setBackgroundColor:[UIColor blackColor]];    

    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kTransitionControllerKey);    
    [transitionController setToView:toView];
}

- (void)beginTransition
{
    // Start the animation
    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kTransitionControllerKey); 
    [transitionController beginTransition:[self transition]];

	if ([self respondsToSelector:@selector(_animationBegan)]) { // iOS >= 6.0
		[self _animationBegan];
		[self _notifyDelegateAnimationBeganWithDuration:[[DCSettings sharedSettings] durationForMode:DCTransitionModeSwitch] delay:0.0f];
	} else {
		// Tell SpringBoard that the animation has started.
		Ivar animatingIvar = class_getInstanceVariable([self class], "_animating");
		BOOL *animating = (BOOL *)((char *)self + ivar_getOffset(animatingIvar));
		*animating = YES;
	}
}

- (void)endTransition
{
    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kTransitionControllerKey);

    [[transitionController view] removeFromSuperview];
    [transitionController endTransition];
}

%new
- (void)displayCandyAnimationFinishedWithMode:(DCTransitionMode)mode app:(SBApplication *)app
{
	if ([self respondsToSelector:@selector(_animationBegan)]) { // iOS >= 6.0
		[self _animationEnded];
		[self _notifyDelegateThatAnimationIsDone];
	} else {
		// Tell SpringBoard that the animation has finished.
		Ivar animatingIvar = class_getInstanceVariable([self class], "_animating");
		BOOL *animating = (BOOL *)((char *)self + ivar_getOffset(animatingIvar));
		*animating = NO;

		Ivar workspaceIsReadyForAnimationCleanupIvar = class_getInstanceVariable([self class], "_workspaceIsReadyForAnimationCleanup");
		BOOL *workspaceIsReadyForAnimationCleanup = (BOOL *)((char *)self + ivar_getOffset(workspaceIsReadyForAnimationCleanupIvar));

		if (*workspaceIsReadyForAnimationCleanup) {
			[[self delegate] appTransitionViewAnimationDidStop:self];
		}
	}
}

%end
