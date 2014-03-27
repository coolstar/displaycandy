#import <QuartzCore/QuartzCore.h>

#import "DCTypes.h"
#import "DCSwingTransitionView.h"

@interface DCSwingTransitionView ()

- (CGPoint)anchorPointForDirection:(DCTransitionDirection)direction launching:(BOOL)launching;
- (CATransform3D)rotationTransformForDirection:(DCTransitionDirection)direction launching:(BOOL)launching;

@end

@implementation DCSwingTransitionView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		_fromViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self addSubview:_fromViewContainer];

		_toViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self addSubview:_toViewContainer];
	}

	return self;
}

- (void)dealloc
{
	[_fromViewContainer release];
	[_toViewContainer release];

	[super dealloc];
}

- (void)setFromView:(UIView *)view
{
	[super setFromView:view];

	[view setOpaque:YES];
	[view setCenter:[_fromViewContainer center]];

	[_fromViewContainer addSubview:view];
}

- (void)setToView:(UIView *)view
{
	[super setToView:view];

	[view setOpaque:YES];
	[view setHidden:YES];
	[view setCenter:[_toViewContainer center]];

	[_toViewContainer addSubview:view];
}

- (void)animateWithDuration:(CFTimeInterval)duration
{
	BOOL isLaunching = ([self mode] == DCTransitionModeLaunch);

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

	UIView *viewToRotate = (isLaunching ? _toViewContainer : _fromViewContainer);	 
	 
	// Set the layer's anchor point depending on the direction.
	[[viewToRotate layer] setAnchorPoint:[self anchorPointForDirection:[self direction] launching:isLaunching]];	
	[[viewToRotate layer] setZPosition:1000];

	// Adjust the center point depending on the anchor point. 
	CGPoint center = [self center];
	CGPoint anchor = [[viewToRotate layer] anchorPoint];

	center.x = [viewToRotate frame].size.width * anchor.x;
	center.y = [viewToRotate frame].size.height * anchor.y;

	[viewToRotate setCenter:center];

	CATransform3D originalTransform = [[viewToRotate layer] transform];
	CATransform3D rotation = [self rotationTransformForDirection:[self direction] launching:isLaunching];
	rotation = CATransform3DConcat(originalTransform, rotation);

	// Choose the correct origin & destination transform based on whether the app is being opened or closed.
	NSValue *fromTransform = [NSValue valueWithCATransform3D:(isLaunching ? rotation : originalTransform)];
	NSValue *toTransform = [NSValue valueWithCATransform3D:(isLaunching ? originalTransform : rotation)];
	
	CABasicAnimation *swing = [CABasicAnimation animationWithKeyPath:@"transform"];
	[swing setDelegate:[self delegate]];	
	[swing setFromValue:fromTransform];
	[swing setToValue:toTransform];
	[swing setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[swing setDuration:duration];
	[swing setFillMode:kCAFillModeForwards];
	[swing setRemovedOnCompletion:NO];
	
	[self bringSubviewToFront:viewToRotate];
	
	[[viewToRotate layer] addAnimation:swing forKey:nil];
	[[black layer] addAnimation:fade forKey:nil];
}

- (CGPoint)anchorPointForDirection:(DCTransitionDirection)direction launching:(BOOL)launching
{
	switch ([self direction]) {
		case DCTransitionDirectionLeft:
			return CGPointMake((launching ? 1.0 : 0.0), 0.5);
		case DCTransitionDirectionRight:
			return CGPointMake((launching ? 0.0 : 1.0), 0.5);
		case DCTransitionDirectionUp:
			return CGPointMake(0.5, (launching ? 1.0 : 0.0));
		case DCTransitionDirectionDown:
			return CGPointMake(0.5, (launching ? 0.0 : 1.0));
		default:
			return CGPointMake(0.5, 0.5);
		
	}
}

- (CATransform3D)rotationTransformForDirection:(DCTransitionDirection)direction launching:(BOOL)launching
{
	double xRotationFactor = 0.0;
	double yRotationFactor = 0.0;
	double zRotationFactor = 0.0;
	
	CATransform3D rotation = CATransform3DIdentity;
	rotation.m34 = 1.0 / -400; // Perspective.

	switch ([self direction]) {
		case DCTransitionDirectionLeft:
			yRotationFactor = (launching ? -1.0 : 1.0);
			break;
		case DCTransitionDirectionRight:
			yRotationFactor = (launching ? 1.0 : -1.0);
			break;
		case DCTransitionDirectionUp:
			xRotationFactor = (launching ? 1.0 : -1.0);
			break;
		case DCTransitionDirectionDown:
			xRotationFactor = (launching ? -1.0 : 1.0);
	}

	rotation = CATransform3DRotate(rotation, M_PI_2, xRotationFactor, yRotationFactor, zRotationFactor);

	return rotation;
}


@end
