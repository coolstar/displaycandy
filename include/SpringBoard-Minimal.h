#import <Foundation/Foundation.h>

@interface UIApplication (SpringBoard)
- (UIInterfaceOrientation)activeInterfaceOrientation;
- (void)hideSpringBoardStatusBar;
- (void)showSpringBoardStatusBar;
@end

@interface SBAlertItemsController : NSObject
+ (id)sharedInstance;
- (void)setForceAlertsToPend:(BOOL)pend;
- (BOOL)deactivateAlertForMenuClickOrSystemGestureWithAnimation:(BOOL)animation;
@end

@interface SBMiniAlertController : NSObject
+ (id)sharedInstance;
- (void)deactivateAlertItemsForDisplay:(id)display;
@end

@interface SBShowcaseController
- (void)setHidden:(BOOL)hidden;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
+ (id)zoomViewForApplication:(id)arg1 includeStatusBar:(BOOL)arg2 includeBanner:(BOOL)arg3 includeRoundedCorners:(BOOL)arg4 canUseIOSurface:(BOOL)arg5 decodeImage:(BOOL)arg6;
- (void)cleanUpAfterZoomAnimation;
- (void)clearZoomLayer;
- (UIView *)rootView;
- (UIView *)contentView;
- (UIView *)wallpaperView;
- (UIView *)window;
- (BOOL)isSwitcherShowing;
- (void)animateApplicationActivationDidStop:(id)animateApplicationActivation finished:(id)finished context:(void *)context;
- (void)applicationSuspendAnimationWillStart:(id)applicationSuspendAnimation context:(void *)context;
- (void)applicationSuspendAnimationDidStop:(id)applicationSuspendAnimation finished:(id)finished context:(void *)context;
- (void)_beginTransitionFromApp:(id)app toApp:(id)app2;
- (void)appTransitionViewAnimationDidStop:(id)appTransitionViewAnimation;
- (UIView *)_zoomViewForAppDosado:(id)appDosado includeStatusBar:(BOOL)bar includeBanner:(BOOL)banner;
- (void)_dismissShowcase:(double)showcase;
- (void)stopRestoringIconList;
- (void)tearDownIconListAndBar;
- (void)restoreIconListAnimated:(BOOL)animated;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
- (void)zoomWallpaper:(BOOL)wallpaper startTime:(double)time duration:(double)duration;
- (void)_ignoreEvents;
- (void)_resumeEventsIfNecessary;
- (void)_hideKeyboard;
- (void)clearFakeSpringBoardStatusBarAndCorners;
- (void)clearFakeSpringBoardStatusBar;
@end

@interface SBIconView : UIView
- (UIImageView *)iconImageView;
- (void)removeAllIconAnimations;
@end

@interface SBProcess : NSObject
@property(readonly, assign) unsigned eventPort;
@end

@interface SBIconViewMap : NSObject
+ (id)homescreenMap;
- (id)iconViewForIcon:(id)arg1;
@end

@interface SBIconModel : NSObject
- (id)applicationIconForDisplayIdentifier:(id)displayIdentifier;
- (id)leafIconForWebClipIdentifier:(id)webClipIdentifier;
@end

@interface SBIconController : NSObject
+ (id)sharedInstance;
- (UIView *)dockContainerView;
- (SBIconView *)currentRootIconList;
- (SBIconModel *)model;
@end

@interface SBDisplayStack : NSObject
- (BOOL)isEmpty;
- (void)pushDisplay:(id)display;
- (id)pop;
- (id)popDisplay:(id)display;
- (id)displays;
- (BOOL)contains;
- (id)topDisplay;
- (id)topApplication;
- (id)topAlert;
@end

@interface SBDisplay : NSObject
- (void)clearDisplaySettings;
- (void)setDisplaySetting:(unsigned)setting flag:(BOOL)flag;
- (void)setDisplaySetting:(unsigned)setting value:(id)value;
- (id)displayValue:(unsigned)value;
- (BOOL)displayFlag:(unsigned)flag;
- (void)clearActivationSettings;
- (void)setActivationSetting:(unsigned)setting flag:(BOOL)flag;
- (void)setActivationSetting:(unsigned)setting value:(id)value;
- (id)activationValue:(unsigned)value;
- (BOOL)activationFlag:(unsigned)flag;
- (void)clearDeactivationSettings;
- (void)setDeactivationSetting:(unsigned)setting flag:(BOOL)flag;
- (void)setDeactivationSetting:(unsigned)setting value:(id)value;
- (id)deactivationValue:(unsigned)value;
- (BOOL)deactivationFlag:(unsigned)flag;
- (void)activate;
- (void)launchSucceeded:(BOOL)succeeded;
- (void)deactivate;
- (void)deactivated;
- (void)deactivateAfterLocking;
- (int)defaultStatusBarStyle;
- (int)statusBarStyle;
- (int)statusBarStyleOverridesToCancel;
- (BOOL)defaultStatusBarHidden;
- (BOOL)statusBarHidden;
- (int)statusBarOrientation;
- (id)description;
- (id)descriptionForDisplaySetting:(unsigned)displaySetting;
- (id)displaySettingsDescription;
- (id)descriptionForActivationSetting:(unsigned)activationSetting;
- (id)activationSettingsDescription;
- (id)descriptionForDeactivationSetting:(unsigned)deactivationSetting;
- (id)deactivationSettingsDescription;
@end

@interface SBBulletinListController : NSObject
+ (id)sharedInstance;
- (void)hideListViewAnimated:(BOOL)animated;
@end

@interface SBBulletinWindowController : NSObject
+ (id)sharedInstance;
- (void)setBusy:(BOOL)busy forReason:(id)reason;
@end

@interface SBApplication : SBDisplay
@property(retain, nonatomic) SBProcess *process;
- (NSString *)displayIdentifier;
- (id)contextHostManager;
- (id)contextHostViewForRequester:(id)requester;
- (id)contextHostViewForRequester:(id)requester enableAndOrderFront:(BOOL)front;
- (void)disableContextHostingForRequester:(id)requester;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(id)arg1;
@end

@interface SBAppContextHostManager : NSObject
- (void)setContextId:(unsigned)anId hidden:(BOOL)hidden forRequester:(id)requester;
- (void)disableHostingForRequester:(id)requester;
- (void)disableHostingForAllRequesters;
@end

@interface SBAppToAppTransitionView : UIView
@property(assign, nonatomic) id delegate;
@property(retain, nonatomic) SBApplication *toApp;
@property(assign, nonatomic) int orientation;
- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)setFromView:(id)view;
- (void)setToView:(id)view;
@end

@interface SBUIAnimationController : NSObject
@property(readonly, nonatomic) UIView *containerView;
@property(retain, nonatomic) SBApplication *deactivatingApp; 
@property(retain, nonatomic) SBApplication *activatingApp;
- (void)_noteAnimationDidCommit:(BOOL)arg1 withDuration:(double)arg2 afterDelay:(double)arg3;
- (void)_noteAnimationDidFinish:(BOOL)arg1;
- (void)_noteAnimationDidFinish;
@end

@interface SBAppToAppTransitionController : SBUIAnimationController 
@property(retain, nonatomic) SBAppToAppTransitionView *transitionView;
@end

@interface SBUIAnimationZoomUpApp : SBUIAnimationController
@end

@interface SBUIAnimationZoomDownApp : SBUIAnimationController
@end

@interface SBFWallpaperView : UIView
@end