#import "DCZoomTransitionView.h"
#import "SpringBoard-Minimal.h"

@implementation DCZoomTransitionView

- (void)animateWithDuration:(CFTimeInterval)duration
{
	id iconModel = nil;
	object_getInstanceVariable([%c(SBIconController) sharedInstance], "_iconModel", (void **)&iconModel);

	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:[self applicationIdentifier]];
	unsigned urlActivationFlag = (%c(SBUIAnimationController) ? 4 : 3);
	NSString *url = [[application activationValue:urlActivationFlag] absoluteString];

	id applicationIcon = (%c(SBUIAnimationController) && [url hasPrefix:@"webclip:"])
						 ? [iconModel leafIconForWebClipIdentifier:[url substringFromIndex:8]]
						 : [iconModel applicationIconForDisplayIdentifier:[self applicationIdentifier]];

	UIImageView *iconView = [[[%c(SBIconViewMap) homescreenMap] iconViewForIcon:applicationIcon] iconImageView];

	// Get the icon position relative to SpringBoard's main window.
	CGRect iconFrame = [self convertRect:[iconView frame] fromView:[iconView superview]];
	CGSize viewSize = [self frame].size;

	BOOL isSwitcherShowing = [[%c(SBUIController) sharedInstance] isSwitcherShowing];
	CGFloat scaleFactor = viewSize.width / iconFrame.size.width;

	CGSize sizeFromIconToScreenCenter = (!isSwitcherShowing && CGRectIntersectsRect(iconFrame, [self frame]))
										? CGSizeMake((viewSize.width / 2) - iconFrame.origin.x - (iconFrame.size.width / 2),
													 (viewSize.height / 2) - iconFrame.origin.y - (iconFrame.size.height / 2))
										: CGSizeZero;

	CGFloat appViewHeight = viewSize.height / scaleFactor;
	CGFloat heightDifference = appViewHeight - iconFrame.size.height;
	CGFloat appViewYTranslation = (heightDifference / 2) * (sizeFromIconToScreenCenter.height / (viewSize.height / 2));

	BOOL isLaunching = ([self mode] == DCTransitionModeLaunch);

	// Homescreen animation.
	{
		UIView *homescreenView = (isLaunching ? [self fromView] : [self toView]);

		CATransform3D homescreenViewOriginalTransform = [[homescreenView layer] transform];	
		CATransform3D homescreenViewZoomTransform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0f);
		homescreenViewZoomTransform = CATransform3DTranslate(homescreenViewZoomTransform, sizeFromIconToScreenCenter.width, sizeFromIconToScreenCenter.height - appViewYTranslation, 0.0f);
		homescreenViewZoomTransform = CATransform3DConcat(homescreenViewOriginalTransform, homescreenViewZoomTransform);

		CABasicAnimation *scaleHomescreenAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
		[scaleHomescreenAnimation setFromValue:[NSValue valueWithCATransform3D:(isLaunching ? homescreenViewOriginalTransform : homescreenViewZoomTransform)]];
		[scaleHomescreenAnimation setToValue:[NSValue valueWithCATransform3D:(isLaunching ? homescreenViewZoomTransform : homescreenViewOriginalTransform)]];
		[scaleHomescreenAnimation setDuration:duration];
		[scaleHomescreenAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		[scaleHomescreenAnimation setFillMode:kCAFillModeForwards];
		[scaleHomescreenAnimation setRemovedOnCompletion:NO];

		[[homescreenView layer] addAnimation:scaleHomescreenAnimation forKey:nil];
	}

	// Application animation.	
	{
		UIView *appView = (isLaunching ? [self toView] : [self fromView]);

		CATransform3D appViewOriginalTransform = [[appView layer] transform];	
		CATransform3D appViewZoomTransform = CATransform3DMakeTranslation(-sizeFromIconToScreenCenter.width, -sizeFromIconToScreenCenter.height + appViewYTranslation, 0.0f);
		appViewZoomTransform = CATransform3DScale(appViewZoomTransform, (1.0f / scaleFactor), (1.0f / scaleFactor), 1.0f);
		appViewZoomTransform = CATransform3DConcat(appViewOriginalTransform, appViewZoomTransform);

		CATransform3D initialTransform = (isLaunching ? appViewZoomTransform : appViewOriginalTransform);
		CATransform3D adjustedTransform = (isLaunching ? appViewOriginalTransform : appViewZoomTransform);

		CFTimeInterval fadeDuration = duration / 2;
		CGFloat initialOpacity = (isLaunching ? 0.0f : 1.0f);
		CGFloat adjustedOpacity = (isLaunching ? 1.0f : 0.0f);

		CABasicAnimation *scaleAppAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
		[scaleAppAnimation setDelegate:[self delegate]];
		[scaleAppAnimation setFromValue:[NSValue valueWithCATransform3D:initialTransform]];
		[scaleAppAnimation setToValue:[NSValue valueWithCATransform3D:adjustedTransform]];
		[scaleAppAnimation setDuration:duration];

		CABasicAnimation *fadeAppAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		[fadeAppAnimation setFromValue:@(initialOpacity)];
		[fadeAppAnimation setToValue:@(adjustedOpacity)];
		[fadeAppAnimation setBeginTime:(isLaunching ? 0.0f : duration - fadeDuration)];
		[fadeAppAnimation setDuration:fadeDuration];

		CAAnimationGroup *appAnimationGroup = [CAAnimationGroup animation];
		[appAnimationGroup setAnimations:@[scaleAppAnimation, fadeAppAnimation]];
		[appAnimationGroup setDelegate:[self delegate]];
		[appAnimationGroup setDuration:duration];
		[appAnimationGroup setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		[appAnimationGroup setFillMode:kCAFillModeForwards];
		[appAnimationGroup setRemovedOnCompletion:NO];

		[self bringSubviewToFront:appView];
		[[self toView] setHidden:NO];
		[[appView layer] addAnimation:appAnimationGroup forKey:nil];
	}
}

@end
