#import <QuartzCore/QuartzCore.h>

#import "DCTypes.h"
#import "DCPushTransitionView.h"

@implementation DCPushTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
	CGPoint fromViewStartPoint;
	CGPoint toViewEndPoint;
	CGSize viewSize = [self frame].size;

	switch ([self direction]) {
		case DCTransitionDirectionLeft:
			fromViewStartPoint = CGPointMake(viewSize.width, 0);
			toViewEndPoint = CGPointMake(-viewSize.width, 0);

			break;
		case DCTransitionDirectionRight:
			fromViewStartPoint = CGPointMake(-viewSize.width, 0);
			toViewEndPoint = CGPointMake(viewSize.width, 0);

			break;
		case DCTransitionDirectionUp:
			fromViewStartPoint = CGPointMake(0, viewSize.height);
			toViewEndPoint = CGPointMake(0, -viewSize.height);

			break;
		case DCTransitionDirectionDown:
			fromViewStartPoint = CGPointMake(0, -viewSize.height);
			toViewEndPoint = CGPointMake(0, viewSize.height);
	}

	[[self toView] setHidden:NO];

	CABasicAnimation *pushFromView = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
	[pushFromView setFromValue:[NSValue valueWithCGPoint:fromViewStartPoint]];	  
	[pushFromView setToValue:[NSValue valueWithCGPoint:CGPointZero]];
	[pushFromView setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[pushFromView setDuration:duration];

	CABasicAnimation *pushToView = [pushFromView copy];
	[pushFromView setDelegate:[self delegate]];
	[pushFromView setFromValue:[NSValue valueWithCGPoint:CGPointZero]];    
	[pushFromView setToValue:[NSValue valueWithCGPoint:toViewEndPoint]];

	[[[self fromView] layer] addAnimation:pushFromView forKey:nil];
	[[[self toView] layer] addAnimation:pushToView forKey:nil];

	[pushToView release];
}

@end
