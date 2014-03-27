#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <IOSurface/IOSurface.h>
#import <GraphicsServices/GraphicsServices.h>
#import "SpringBoard-Minimal.h"
#import "layersnapshotter.h"

#import "DCTypes.h"
#import "DCTransitionDelegate.h"
#import "DCAppToAppWrapperView.h"
#import "DCTransitionController.h"
#import "DCDisplayStackManager.h"
#import "DCSettings.h"

#include "DCFunctions.h"

UIImage* _UICreateScreenUIImage();
void CARenderServerRenderDisplay(kern_return_t, CFStringRef, IOSurfaceRef, int, int);

static DCTransitionController *_transitionController;
static char kZoomUpTransitionControllerKey;
static char kZoomDownTransitionControllerKey;
static char kZoomUpTransitionKey;
static char kZoomDownTransitionKey;

@interface UIImage (IOSurface)
- (id)_initWithIOSurface:(IOSurfaceRef)ioSurface scale:(float)scale orientation:(int)orientation;
@end

@interface UIScreen (iOS5)
- (int)_imageOrientation;
@end

@interface UIStatusBar : UIView
- (void)requestStyle:(int)style animated:(BOOL)animated;
@end

@interface SBUIController (DisplayCandyAdditions)
- (UIImageView *)screenSnapshotView;
- (UIImageView *)homescreenSnapshotView;
@end

void reloadSettings()
{
    [[DCSettings sharedSettings] reload];
}


%group NewMethods
%hook SBUIController

%new
- (UIImageView *)screenSnapshotView
{
    UIImage *screenImage = _UICreateScreenUIImage();
    UIImageView *screen = [[UIImageView alloc] initWithImage:screenImage];
    
    [screenImage release];

    // Rotate the snapshot depending on the orientation.
    CGAffineTransform rotationTransform = DCRotationTransformForCurrentOrientation();
	
    [screen setTransform:rotationTransform];

    return [screen autorelease];
}

%new
- (UIView *)homescreenSnapshotView
{
	[CATransaction flush];

    UIView *homescreen = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, [[self contentView] bounds].size}];
	[homescreen setBackgroundColor:[UIColor blackColor]];

    // Grab a snapshot of contentView.
    UIImage *contentViewSnapshotImage = [[self contentView] renderSnapshot];
    UIImageView *contentViewSnapshot = [[UIImageView alloc] initWithImage:contentViewSnapshotImage];

    [homescreen setCenter:[homescreen center]];
    [homescreen addSubview:contentViewSnapshot];

    [contentViewSnapshot release];

    // Add the status bar
    UIStatusBar *homescreenStatusBar = [[UIStatusBar alloc] initWithFrame:(CGRect){CGPointZero, [homescreen bounds].size}];
    [homescreenStatusBar requestStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    [homescreen addSubview:homescreenStatusBar];
    [homescreenStatusBar release];

    return [homescreen autorelease];
}

%new
- (void)displayCandyAnimationFinishedWithMode:(DCTransitionMode)mode app:(SBApplication *)app
{
    if (mode == DCTransitionModeLaunch) { // Finished launch animation.
		NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:app, [app process], @NO, nil]
														   forKeys:[NSArray arrayWithObjects:@"app", @"process", @"fromBanner", nil]];

        [self animateApplicationActivationDidStop:nil finished:@YES context:dict];
    } else if (mode == DCTransitionModeSuspend) { // Finished suspend animation. 
        [app clearDeactivationSettings];
        [app deactivate];

        [[[DCDisplayStackManager sharedManager] suspendingDisplayStack] popDisplay:app];

        // Hide the app.
        id contextHostView = [app contextHostViewForRequester:@"LaunchSuspend" enableAndOrderFront:YES];
        [contextHostView setHidden:YES];

        // Show the status bar.
        [(SpringBoard *)[%c(SpringBoard) sharedApplication] showSpringBoardStatusBar];

        // Tell SpringBoard it is now safe to push alerts or allow the NC to be activated.
        [[%c(SBAlertItemsController) sharedInstance] setForceAlertsToPend:NO];
        [[%c(SBBulletinWindowController) sharedInstance] setBusy:NO forReason:@"SuspendAnimation"];
        [[%c(SBUIController) sharedInstance] _resumeEventsIfNecessary];

        // Clear the transition view.
        [[self rootView] setAlpha:1.0];
        [self cleanUpAfterZoomAnimation];
    }
}

%end
%end

%group iOS5
%hook SBUIController

- (void)clearZoomLayer
{
    %orig;

    [[_transitionController view] removeFromSuperview];
    [_transitionController endTransition];
    [_transitionController release];
    _transitionController = nil;
}

- (void)animateApplicationActivation:(id)application animateDefaultImage:(BOOL)image scatterIcons:(BOOL)icons
{
    BOOL appToApp = [application activationFlag:0x14];
    DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeLaunch];

    if (![[DCSettings sharedSettings] isEnabled] || [application activationFlag:0x06] || [application activationFlag:0x18] || transition == 0 || (transition == 0 && !appToApp) || appToApp) {
        %orig;
    } else {
        // Snapshot the screen.
        UIImageView *screen = [self screenSnapshotView];

        // Get the application's launch image.
        UIView *zoomView = [self _zoomViewForAppDosado:application
									  includeStatusBar:![application statusBarHidden]
										 includeBanner:NO]; 

        [zoomView setBackgroundColor:[UIColor blackColor]];

        // Rotate the zoom view depending on the orientation.
        CGAffineTransform rotationTransform = DCRotationTransformForCurrentOrientation();
        [zoomView setTransform:rotationTransform];

        // Hide rootView.
        [[self rootView] setAlpha:0.0f];

        // Close any showcase views (Switcher, Siri), hide the keyboard and statusbar.
        [self _dismissShowcase:0.0];
        [self _hideKeyboard];
        [(SpringBoard *)[%c(SpringBoard) sharedApplication] hideSpringBoardStatusBar];

        // Tell SpringBoard not to push any alerts or allow the Notification Center to be activated.
        [[%c(SBAlertItemsController) sharedInstance] setForceAlertsToPend:YES];
        [[%c(SBBulletinWindowController) sharedInstance] setBusy:YES forReason:@"LaunchAnimation"];

        // Dismiss the notification center.
        [[%c(SBBulletinListController) sharedInstance] hideListViewAnimated:NO];

        // Ignore ALL the events!
        [self _ignoreEvents];

        // Create the transition view.
        _transitionController = [[DCTransitionController alloc] init];
        [_transitionController setDelegate:(id<DCTransitionDelegate>)self];
        [_transitionController setApplication:application];
        [_transitionController setMode:DCTransitionModeLaunch];
        [_transitionController setFromView:screen];
        [_transitionController setToView:zoomView];

        [[self window] addSubview:[_transitionController view]];

        // Start the animation
        [_transitionController beginTransition:transition];
    }
}

- (void)animateApplicationSuspend:(id)application
{
    SBApplication *preactivateApp = [[[DCDisplayStackManager sharedManager] preActivateDisplayStack] topApplication];
    DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeSuspend];    

    if (![[DCSettings sharedSettings] isEnabled] || transition == 0 || [application deactivationFlag:0x01] || [application deactivationFlag:0x03]) {
        %orig;
    } else if ([preactivateApp activationFlag:0x08] || [preactivateApp activationFlag:0x09]) {
        // Switching apps.
        [self _hideKeyboard];
        [self _beginTransitionFromApp:application toApp:preactivateApp];
    } else {
        // Snapshot what's currently on the screen.
        UIImageView *screen = [self screenSnapshotView];
        
        // Manually restore icons and dock, zoom wallpaper.
        [[[self wallpaperView] layer] removeAllAnimations];
        [[[%c(SBIconController) sharedInstance] currentRootIconList] removeAllIconAnimations];
        [[[[%c(SBIconController) sharedInstance] dockContainerView] layer] removeAllAnimations];

        // Snapshot the home screen.
        UIImageView *homescreen = [self homescreenSnapshotView];

        // Tell SpringBoard not to push any alerts or allow the Notification Center to be activated.
        [[%c(SBAlertItemsController) sharedInstance] deactivateAlertForMenuClickOrSystemGestureWithAnimation:YES];
        [[%c(SBAlertItemsController) sharedInstance] setForceAlertsToPend:YES];
        [[%c(SBBulletinWindowController) sharedInstance] setBusy:YES forReason:@"SuspendAnimation"];

		// Close any showcase views (Switcher, Siri), hide the keyboard and statusbar.
        [self _dismissShowcase:0.0];
        [self _hideKeyboard];
        [(SpringBoard *)[%c(SpringBoard) sharedApplication] hideSpringBoardStatusBar];

         // Dismiss the notification center.
        [[%c(SBBulletinListController) sharedInstance] hideListViewAnimated:NO];

        // Hide rootView,
        [[self rootView] setAlpha:0.0f];

        // Close any showcase views (Switcher, Siri).
        [self _dismissShowcase:0.0];

        // Hide alerts.
        [[%c(SBMiniAlertController) sharedInstance] deactivateAlertItemsForDisplay:application];

        // Hide keyboard.
        [self _hideKeyboard];        

        // Add the app's context host view to SpringBoard's window to make sure it hides when the app is suspended.
        id contextHostView = [application contextHostViewForRequester:@"LaunchSuspend" enableAndOrderFront:YES];
        [[self window] addSubview:contextHostView];

        // Tell SpringBoard the app is hidden.
        [[application contextHostManager] setContextId:[[application displayValue:8] intValue] hidden:YES forRequester:@"LaunchSuspend"];

        // Ignore ALL the events!
        [self _ignoreEvents];

        // Create the transition view.
        _transitionController = [[DCTransitionController alloc] init];
        [_transitionController setDelegate:(id<DCTransitionDelegate>)self];
        [_transitionController setApplication:application];
        [_transitionController setMode:DCTransitionModeSuspend];
        [_transitionController setFromView:screen];
        [_transitionController setToView:homescreen];

        [[self window] addSubview:[_transitionController view]];

        // Start the animation
        [_transitionController beginTransition:transition];
    }
}

%end

%hook SBAppToAppTransitionController

- (id)init
{
    self = %orig;

	DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeLaunch];	

    if (self && [[DCSettings sharedSettings] isEnabled] && [[DCSettings sharedSettings] transitionForMode:DCTransitionModeSwitch] != 0) {
        // Remove existing transition view;
        UIView *transitionView;
        object_getInstanceVariable(self, "_transitionView", (void **)&transitionView);

        [transitionView removeFromSuperview];

        // Create a wrapper for DCTransitionController's view (so that standard SpringBoard methods can be utilised).
        UIWindow *transitionWindow;
        object_getInstanceVariable(self, "_transitionWindow", (void **)&transitionWindow);

		CGSize windowSize = [transitionWindow frame].size;
        DCAppToAppWrapperView *wrapperView = [[%c(DCAppToAppWrapperView) alloc] initWithFrame:(CGRect){CGPointZero, windowSize}];
		[wrapperView setTransition:transition];		

        object_setInstanceVariable(self, "_transitionView", wrapperView);

        [transitionWindow addSubview:wrapperView];
    }

    return self;
}

%end
%end

%group iOS6
%hook SBUIAnimationZoomUpApp

- (void)_prepareAnimation
{
	%orig;

	Ivar doFadeInsteadOfZoomIvar = class_getInstanceVariable([self class], "_doFadeInsteadOfZoom");
    BOOL *doFadeInsteadOfZoom = (BOOL *)((char *)self + ivar_getOffset(doFadeInsteadOfZoomIvar));

	DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeLaunch];

	if ([[DCSettings sharedSettings] isEnabled] && transition != 0 && !*doFadeInsteadOfZoom && ![[self activatingApp] activationFlag:0x18]) {
		objc_setAssociatedObject(self, &kZoomUpTransitionKey, @(transition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);	
		[[%c(SBUIController) sharedInstance] clearFakeSpringBoardStatusBarAndCorners];

		// Snapshot the screen.
        UIImageView *screen = [[%c(SBUIController) sharedInstance] screenSnapshotView];

        // Get the application's launch image.
        UIView *zoomView = [%c(SBUIController) zoomViewForApplication:[self activatingApp]
													 includeStatusBar:![[self activatingApp] statusBarHidden]
														includeBanner:NO
												includeRoundedCorners:YES
												      canUseIOSurface:YES
														  decodeImage:YES];

        [zoomView setBackgroundColor:[UIColor blackColor]];

        // Rotate the zoom view depending on the orientation.
        CGAffineTransform rotationTransform = DCRotationTransformForCurrentOrientation();
        [zoomView setTransform:rotationTransform];

		// Create the transition view.
		DCTransitionController *transitionController = [[DCTransitionController alloc] init];
		[transitionController setApplication:[self activatingApp]];
		[transitionController setDelegate:(id<DCTransitionDelegate>)self];
		[transitionController setMode:DCTransitionModeLaunch];
		[transitionController setFromView:screen];
		[transitionController setToView:zoomView];

		[[self containerView] addSubview:[transitionController view]];

		objc_setAssociatedObject(self, &kZoomUpTransitionControllerKey, transitionController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[transitionController release];
	}
}

- (void)_startAnimation
{
	DCTransition transition = [objc_getAssociatedObject(self, &kZoomUpTransitionKey) intValue];
    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kZoomUpTransitionControllerKey);	

    if ([[DCSettings sharedSettings] isEnabled] && transition != 0) {
		// Close any showcase views (Switcher, Siri), hide the keyboard and statusbar.
        [[%c(SBUIController) sharedInstance] _dismissShowcase:0.0];
        [[%c(SBUIController) sharedInstance] _hideKeyboard];

        // Start the animation.
        [transitionController beginTransition:transition];
		[self _noteAnimationDidCommit:YES withDuration:[[DCSettings sharedSettings] durationForMode:DCTransitionModeLaunch] afterDelay:0.0f];
	} else {
        %orig;
	}
}

- (void)_cleanupAnimation
{
	%orig;
	
    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kZoomUpTransitionControllerKey);	

	[[transitionController view] removeFromSuperview];
    [transitionController endTransition];
}

%new
- (void)displayCandyAnimationFinishedWithMode:(DCTransitionMode)mode app:(SBApplication *)app
{
	[self _noteAnimationDidFinish:YES];	
}

%end

%hook SBUIAnimationZoomDownApp

- (void)_prepareAnimation
{
	%orig;

	[[%c(SBUIController) sharedInstance] restoreIconListAnimated:NO];

	DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeSuspend];

	if ([[DCSettings sharedSettings] isEnabled] && transition != 0) {
		objc_setAssociatedObject(self, &kZoomDownTransitionKey, @(transition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);		
		[[%c(SBUIController) sharedInstance] clearFakeSpringBoardStatusBarAndCorners];
		
		// Snapshot the screen.
        UIImageView *screen = [[%c(SBUIController) sharedInstance] screenSnapshotView];

		// Create the transition view.
		DCTransitionController *transitionController = [[DCTransitionController alloc] init];
		[transitionController setApplication:[self deactivatingApp]];
		[transitionController setDelegate:(id<DCTransitionDelegate>)self];
		[transitionController setMode:DCTransitionModeSuspend];

		// Hack to stop a quick flash of the homescreen from appearing.
		[screen setFrame:(CGRect){CGPointZero, [screen frame].size}];
		[[[%c(SBUIController) sharedInstance] rootView] addSubview:screen];

		// Snapshot the home screen.
        UIImageView *homescreen = [[%c(SBUIController) sharedInstance] homescreenSnapshotView];

		[screen removeFromSuperview];

		[transitionController setFromView:screen];		
		[transitionController setToView:homescreen];

		[[self containerView] addSubview:[transitionController view]];

		objc_setAssociatedObject(self, &kZoomDownTransitionControllerKey, transitionController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[transitionController release];
	}
}

- (void)_startAnimation
{
	DCTransition transition = [objc_getAssociatedObject(self, &kZoomDownTransitionKey) intValue];
    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kZoomDownTransitionControllerKey);	

    if ([[DCSettings sharedSettings] isEnabled] && transition != 0) {
		// Close any showcase views (Switcher, Siri), hide the keyboard and statusbar.
        [[%c(SBUIController) sharedInstance] _dismissShowcase:0.0];
        [[%c(SBUIController) sharedInstance] _hideKeyboard];
		[[%c(SBUIController) sharedInstance] stopRestoringIconList];

        // Start the animation.
        [transitionController beginTransition:transition];
		[self _noteAnimationDidCommit:YES withDuration:[[DCSettings sharedSettings] durationForMode:DCTransitionModeLaunch] afterDelay:0.0f];
	} else {
        %orig;
	}
}

- (void)_cleanupAnimation
{
	%orig;

    DCTransitionController *transitionController = objc_getAssociatedObject(self, &kZoomDownTransitionControllerKey);	

	[[transitionController view] removeFromSuperview];
    [transitionController endTransition];
}

%new
- (void)displayCandyAnimationFinishedWithMode:(DCTransitionMode)mode app:(SBApplication *)app
{
	[self _noteAnimationDidFinish:YES];	
}

%end

%hook SBAppToAppTransitionController

- (id)initWithActivatingApp:(id)arg1 deactivatingApp:(id)arg2
{
    self = %orig;
	
	DCTransition transition = [[DCSettings sharedSettings] transitionForMode:DCTransitionModeSwitch];

    if (self && [[DCSettings sharedSettings] isEnabled] && transition != 0) {
        // Remove existing transition view;
        [[self transitionView] removeFromSuperview];
		[self setTransitionView:nil];

        // Create a wrapper for DCTransitionController's view (so that standard SpringBoard methods can be utilised).
		CGSize windowSize = [[self containerView] frame].size;
        DCAppToAppWrapperView *wrapperView = [[%c(DCAppToAppWrapperView) alloc] initWithFrame:(CGRect){CGPointZero, windowSize}];
		[wrapperView setDelegate:(id<DCTransitionDelegate>)self];
		[wrapperView setTransition:transition];

		[self setTransitionView:wrapperView];
        [[self containerView] addSubview:wrapperView];

		[wrapperView release];
    }

    return self;
}

%end
%end

%ctor
{
	%init(NewMethods);

	if (%c(SBUIAnimationController)) {
		%init(iOS6);
	} else {
		%init(iOS5);
	}

    // Make sure layersnapshotter is loaded.
    dlopen("/usr/lib/liblayersnapshotter.dylib", RTLD_LAZY);

    // Register ourselves as an observer for the settings notification.
    CFNotificationCenterRef notifyCenter = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(notifyCenter, NULL, (CFNotificationCallback)reloadSettings, CFSTR("com.protosphere.displaycandy.settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
