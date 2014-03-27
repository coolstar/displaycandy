#import <QuartzCore/QuartzCore.h>

#import "DCTypes.h"
#import "DCRevealTransitionView.h"

@implementation DCRevealTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
	CGPoint endPoint;
	CGSize viewSize = [self frame].size;

	switch ([self direction]) {
		case DCTransitionDirectionLeft:
			endPoint = CGPointMake(-viewSize.width, 0);
			break;
		case DCTransitionDirectionRight:
			endPoint = CGPointMake(viewSize.width, 0);
			break;

		case DCTransitionDirectionUp:
			endPoint = CGPointMake(0, -viewSize.height);
			break;
		
		case DCTransitionDirectionDown:
			endPoint = CGPointMake(0, viewSize.height);
	}

	[self bringSubviewToFront:[self fromView]];
	[[self toView] setHidden:NO];

	CABasicAnimation *reveal = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
	[reveal setDelegate:[self delegate]];
	[reveal setValue:@([self mode]) forKey:@"mode"];
	[reveal setFromValue:[NSValue valueWithCGPoint:CGPointZero]];	 
	[reveal setToValue:[NSValue valueWithCGPoint:endPoint]];
	[reveal setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[reveal setDuration:duration];
	[reveal setFillMode:kCAFillModeForwards];
	[reveal setRemovedOnCompletion:NO];

	[[[self fromView] layer] addAnimation:reveal forKey:nil];
}

@end
