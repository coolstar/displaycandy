#import <QuartzCore/QuartzCore.h>

#import "DCTypes.h"
#import "DCCoverTransitionView.h"

@implementation DCCoverTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
	CGPoint startPoint;
	CGSize viewSize = [self frame].size;

	switch ([self direction]) {
		case DCTransitionDirectionLeft:
			startPoint = CGPointMake(viewSize.width, 0);
			break;
		case DCTransitionDirectionRight:
			startPoint = CGPointMake(-viewSize.width, 0);
			break;
		case DCTransitionDirectionUp:
			startPoint = CGPointMake(0, viewSize.height);
			break;
		case DCTransitionDirectionDown:
			startPoint = CGPointMake(0, -viewSize.height);
			break;
	}
	
	[[self toView] setHidden:NO];

	CABasicAnimation *cover = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
	[cover setDelegate:[self delegate]];
	[cover setValue:@([self mode]) forKey:@"mode"];
	[cover setFromValue:[NSValue valueWithCGPoint:startPoint]];    
	[cover setToValue:[NSValue valueWithCGPoint:CGPointZero]];
	[cover setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[cover setDuration:duration];

	[[[self toView] layer] addAnimation:cover forKey:nil];
}

@end
