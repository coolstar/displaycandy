#import <UIKit/UIKit.h>
#import "DCTransitionView.h"

@implementation DCTransitionView

- (void)setFromView:(UIView *)view
{
	[_fromView release];
	_fromView = [view retain];

	[_fromView setOpaque:YES];
	[_fromView setCenter:[self center]];

	[self addSubview:_fromView];
}

- (void)setToView:(UIView *)view
{
	[_toView release];
	_toView = [view retain];

	[_toView setOpaque:YES];
	[_toView setHidden:YES];
	[_toView setCenter:[self center]];

	[self addSubview:_toView];
}

- (void)animateWithDuration:(CFTimeInterval)duration {}

- (void)dealloc
{
	[_fromView release];
	[_toView release];

	[super dealloc];
}

@end
