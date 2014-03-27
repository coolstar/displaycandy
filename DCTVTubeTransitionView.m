#import <QuartzCore/QuartzCore.h>

#import "DCTypes.h"
#import "DCTVTubeTransitionView.h"

@implementation DCTVTubeTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
	isLaunching = ([self mode] == DCTransitionModeLaunch);
	stepDuration = duration / 2;

	UIView *black = [[UIView alloc] initWithFrame:[self frame]];
	[black setBackgroundColor:[UIColor blackColor]];
	[black setAlpha:(isLaunching ? 1.0f : 0.0f)];

	[self addSubview:black];
	[black release];

	[[self toView] setHidden:NO];

	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	[fade setFromValue:@(isLaunching ? 0.0f : 1.0f)];
	[fade setToValue:@(isLaunching ? 1.0f : 0.0f)];
	[fade setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];    
	[fade setDuration:duration];

	CGSize viewSize = [self frame].size;
	UIView *viewToTransform = (isLaunching ? [self toView] : [self fromView]);
	originalTransform = [[viewToTransform layer] transform];

	horizontalSquashTransform = CATransform3DMakeScale(2.0f / viewSize.width, 2.0f / viewSize.height, 1.0f);
	horizontalExpandTransform = CATransform3DMakeScale(1.0f, 2.0f / viewSize.height, 1.0f);
	verticalSquashTransform = CATransform3DMakeScale(1.0f, 2.0f / viewSize.height, 1.0f);

	// Choose the correct origin & destination transform based on whether the app is being opened or closed.
	CATransform3D *fromTransform = (isLaunching ? &horizontalSquashTransform : &originalTransform);    
	CATransform3D *toTransform = (isLaunching ? &horizontalExpandTransform : &verticalSquashTransform);

	// Concatenate the view's original transform with the animation transform to preserve rotation.
	*fromTransform = CATransform3DConcat(originalTransform, *fromTransform);
	*toTransform = CATransform3DConcat(originalTransform, *toTransform);

	CABasicAnimation *stepOne = [CABasicAnimation animationWithKeyPath:@"transform"];
	[stepOne setDelegate:self];
	[stepOne setFromValue:[NSValue valueWithCATransform3D:*fromTransform]];
	[stepOne setToValue:[NSValue valueWithCATransform3D:*toTransform]];
	[stepOne setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	[stepOne setDuration:stepDuration];
	[stepOne setFillMode:kCAFillModeForwards];
	[stepOne setRemovedOnCompletion:NO];		

	[self bringSubviewToFront:viewToTransform];
	[[viewToTransform layer] addAnimation:stepOne forKey:nil];

	[[black layer] addAnimation:fade forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	UIView *viewToTransform = (isLaunching ? [self toView] : [self fromView]);

	CATransform3D *toTransform = (isLaunching ? &originalTransform : &horizontalSquashTransform);

	// Concatenate the view's original transform with the animation transform to preserve rotation.
	*toTransform = CATransform3DConcat(originalTransform, *toTransform);

	CABasicAnimation *stepTwo = [CABasicAnimation animationWithKeyPath:@"transform"];
	[stepTwo setDelegate:[self delegate]];
	[stepTwo setToValue:[NSValue valueWithCATransform3D:*toTransform]];
	[stepTwo setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
	[stepTwo setDuration:stepDuration];
	[stepTwo setFillMode:kCAFillModeForwards];
	[stepTwo setRemovedOnCompletion:NO];		

	[[viewToTransform layer] addAnimation:stepTwo forKey:nil];
}

@end
